# -*- coding: utf-8; -*-
#
# SPDX-License-Identifier: GPL-3.0-only

from __future__ import annotations

import logging
import threading
from dataclasses import dataclass
from typing import Callable

from gremlin import common, error, util
from gremlin.types import HatDirection

try:
    import vgamepad as vg
except ImportError:
    vg = None


@dataclass
class _GamepadEntry:

    gamepad: object
    lock: threading.Lock
    axis_state: dict[str, float]


class XboxOutputManager(metaclass=common.SingletonMetaclass):

    """Provides shared access to virtual Xbox 360 controllers."""

    def __init__(self) -> None:
        self._devices: dict[int, _GamepadEntry] = {}

    @staticmethod
    def is_available() -> bool:
        return vg is not None

    def reset(self) -> None:
        for entry in self._devices.values():
            with entry.lock:
                entry.gamepad.reset()
                entry.gamepad.update()

    def set_axis(self, controller_id: int, target: str, value: float) -> None:
        self._with_gamepad(
            controller_id,
            lambda gamepad: self._set_axis_impl(gamepad, target, value)
        )

    def set_button(self, controller_id: int, target: str, is_pressed: bool) -> None:
        self._with_gamepad(
            controller_id,
            lambda gamepad: self._set_button_impl(gamepad, target, is_pressed)
        )

    def set_hat(self, controller_id: int, direction: HatDirection) -> None:
        self._with_gamepad(
            controller_id,
            lambda gamepad: self._set_hat_impl(gamepad, direction)
        )

    def _with_gamepad(
        self,
        controller_id: int,
        callback: Callable[[object], None]
    ) -> None:
        entry = self._get_gamepad(controller_id)
        with entry.lock:
            callback(entry.gamepad)
            entry.gamepad.update()

    def _get_gamepad(self, controller_id: int) -> _GamepadEntry:
        if not self.is_available():
            raise error.GremlinError(
                "vgamepad is not installed; Xbox 360 output is unavailable."
            )
        if controller_id < 1:
            raise error.GremlinError("Xbox controller ids start at 1.")

        while len(self._devices) < controller_id:
            gamepad = vg.VX360Gamepad()
            index = gamepad.get_index()
            self._devices[index] = _GamepadEntry(
                gamepad,
                threading.Lock(),
                {"lx": 0.0, "ly": 0.0, "rx": 0.0, "ry": 0.0}
            )
            logging.getLogger("system").info(
                f"Created virtual Xbox 360 controller #{index}."
            )

        return self._devices[controller_id]

    def _set_axis_impl(self, gamepad: object, target: str, value: float) -> None:
        value = util.clamp(value, -1.0, 1.0)
        entry = self._devices[gamepad.get_index()]
        match target:
            case "left-thumb-x":
                gamepad.left_joystick_float(value, entry.axis_state["ly"])
            case "left-thumb-y":
                gamepad.left_joystick_float(entry.axis_state["lx"], value)
            case "right-thumb-x":
                gamepad.right_joystick_float(value, entry.axis_state["ry"])
            case "right-thumb-y":
                gamepad.right_joystick_float(entry.axis_state["rx"], value)
            case "left-trigger":
                gamepad.left_trigger_float((value + 1.0) / 2.0)
            case "right-trigger":
                gamepad.right_trigger_float((value + 1.0) / 2.0)
            case _:
                raise error.GremlinError(f"Unknown Xbox axis target '{target}'.")

        self._store_axis(entry, target, value)

    def _set_button_impl(
        self,
        gamepad: object,
        target: str,
        is_pressed: bool
    ) -> None:
        if target.startswith("dpad-"):
            button = self._dpad_button(target)
        else:
            button = self._button_lookup(target)
        if is_pressed:
            gamepad.press_button(button=button)
        else:
            gamepad.release_button(button=button)

    def _set_hat_impl(self, gamepad: object, direction: HatDirection) -> None:
        for target in ("dpad-up", "dpad-down", "dpad-left", "dpad-right"):
            gamepad.release_button(button=self._dpad_button(target))

        pressed_targets = {
            HatDirection.North: ("dpad-up",),
            HatDirection.NorthEast: ("dpad-up", "dpad-right"),
            HatDirection.East: ("dpad-right",),
            HatDirection.SouthEast: ("dpad-down", "dpad-right"),
            HatDirection.South: ("dpad-down",),
            HatDirection.SouthWest: ("dpad-down", "dpad-left"),
            HatDirection.West: ("dpad-left",),
            HatDirection.NorthWest: ("dpad-up", "dpad-left"),
        }.get(direction, ())

        for target in pressed_targets:
            gamepad.press_button(button=self._dpad_button(target))

    def _button_lookup(self, target: str) -> int:
        lookup = {
            "a": vg.XUSB_BUTTON.XUSB_GAMEPAD_A,
            "b": vg.XUSB_BUTTON.XUSB_GAMEPAD_B,
            "x": vg.XUSB_BUTTON.XUSB_GAMEPAD_X,
            "y": vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,
            "left-shoulder": vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_SHOULDER,
            "right-shoulder": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_SHOULDER,
            "back": vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK,
            "start": vg.XUSB_BUTTON.XUSB_GAMEPAD_START,
            "guide": vg.XUSB_BUTTON.XUSB_GAMEPAD_GUIDE,
            "left-thumb": vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_THUMB,
            "right-thumb": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_THUMB,
        }
        try:
            return lookup[target]
        except KeyError as exc:
            raise error.GremlinError(
                f"Unknown Xbox button target '{target}'."
            ) from exc

    def _dpad_button(self, target: str) -> int:
        lookup = {
            "dpad-up": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP,
            "dpad-down": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_DOWN,
            "dpad-left": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT,
            "dpad-right": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT,
        }
        try:
            return lookup[target]
        except KeyError as exc:
            raise error.GremlinError(
                f"Unknown Xbox d-pad target '{target}'."
            ) from exc

    def _store_axis(
        self,
        entry: _GamepadEntry,
        target: str,
        value: float
    ) -> None:
        axis_name = {
            "left-thumb-x": "lx",
            "left-thumb-y": "ly",
            "right-thumb-x": "rx",
            "right-thumb-y": "ry",
        }.get(target)
        if axis_name is not None:
            entry.axis_state[axis_name] = value
