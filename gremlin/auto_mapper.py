# -*- coding: utf-8; -*-

# SPDX-License-Identifier: GPL-3.0-only

"""
Auto-mapping from physical DirectInput devices to vJoy or Xbox 360 outputs.
"""

from __future__ import annotations

from collections.abc import Iterable
import dataclasses
import itertools
from typing import List, Self

from PySide6 import QtCore

from action_plugins import map_to_vjoy, map_to_xbox360, root
import dill
from gremlin import (
    device_initialization,
    plugin_manager,
    profile,
    shared_state,
    types,
)


@dataclasses.dataclass
class AutoMapperOptions:

    """Options for the vJoy auto-mapper."""

    mode: str = "Default"
    repeat_vjoy_inputs: bool = False
    overwrite_used_inputs: bool = False


@dataclasses.dataclass
class XboxAutoMapperOptions:

    """Options for the Xbox 360 auto-mapper."""

    mode: str = "Default"
    controller_id: int = 1
    overwrite_used_inputs: bool = False


class _BaseAutoMapper:

    def __init__(self, profile_data: profile.Profile) -> None:
        self._profile = profile_data
        self._num_retained_bindings = 0

    @staticmethod
    def _tr(text: str) -> str:
        return QtCore.QCoreApplication.translate("AutoMapper", text)

    @classmethod
    def from_current_profile(cls) -> Self:
        return cls(shared_state.current_profile)

    def _prepare_profile(
        self,
        input_devices: list[dill.DeviceSummary],
        overwrite_used_inputs: bool
    ) -> None:
        if overwrite_used_inputs:
            for dev in input_devices:
                self._profile.inputs.pop(dev.device_guid.uuid, None)

    def _iter_physical_axes(
        self,
        input_devices: list[dill.DeviceSummary],
        mode: str,
    ) -> Iterable[profile.InputItem]:
        for dev in input_devices:
            for linear_index in range(dev.axis_count):
                axis_index = dev.axis_map[linear_index].axis_index
                input_item = self._profile.get_input_item(
                    dev.device_guid.uuid,
                    types.InputType.JoystickAxis,
                    axis_index,
                    mode,
                    create_if_missing=True,
                )
                if not input_item.action_sequences:
                    yield input_item
                else:
                    self._num_retained_bindings += 1

    def _iter_physical_buttons(
        self,
        input_devices: list[dill.DeviceSummary],
        mode: str,
    ) -> Iterable[profile.InputItem]:
        for dev in input_devices:
            for button in range(1, dev.button_count + 1):
                input_item = self._profile.get_input_item(
                    dev.device_guid.uuid,
                    types.InputType.JoystickButton,
                    button,
                    mode,
                    create_if_missing=True,
                )
                if not input_item.action_sequences:
                    yield input_item
                else:
                    self._num_retained_bindings += 1

    def _iter_physical_hats(
        self,
        input_devices: list[dill.DeviceSummary],
        mode: str,
    ) -> Iterable[profile.InputItem]:
        for dev in input_devices:
            for hat in range(1, dev.hat_count + 1):
                input_item = self._profile.get_input_item(
                    dev.device_guid.uuid,
                    types.InputType.JoystickHat,
                    hat,
                    mode,
                    create_if_missing=True,
                )
                if not input_item.action_sequences:
                    yield input_item
                else:
                    self._num_retained_bindings += 1


class AutoMapper(_BaseAutoMapper):

    """Generates "Map to vJoy" actions for physical input devices."""

    def __init__(self, profile_data: profile.Profile) -> None:
        super().__init__(profile_data)
        self._created_mappings: list[map_to_vjoy.MapToVjoyData] = []

    def generate_mappings(
        self,
        input_devices_guids: List[dill.GUID],
        output_vjoy_ids: List[int],
        options: AutoMapperOptions,
    ) -> str:
        if not input_devices_guids:
            return self._tr("No input devices selected")
        if not output_vjoy_ids:
            return self._tr("No vJoy devices selected")

        input_devices = [
            dev
            for dev in device_initialization.physical_devices()
            if dev.device_guid in input_devices_guids
        ]

        self._prepare_profile(input_devices, options.overwrite_used_inputs)
        self._num_retained_bindings = 0
        used_vjoy_inputs = set(self._get_used_vjoy_inputs(options.mode))
        vjoy_axes = self._iter_unused_vjoy_axes(output_vjoy_ids, used_vjoy_inputs)
        vjoy_buttons = self._iter_unused_vjoy_buttons(
            output_vjoy_ids, used_vjoy_inputs
        )
        vjoy_hats = self._iter_unused_vjoy_hats(output_vjoy_ids, used_vjoy_inputs)
        if options.repeat_vjoy_inputs:
            vjoy_axes = itertools.cycle(vjoy_axes)
            vjoy_buttons = itertools.cycle(vjoy_buttons)
            vjoy_hats = itertools.cycle(vjoy_hats)

        for physical_axis, vjoy_axis in zip(
            self._iter_physical_axes(input_devices, options.mode), vjoy_axes
        ):
            self._create_new_mapping(physical_axis, vjoy_axis)
        for physical_button, vjoy_button in zip(
            self._iter_physical_buttons(input_devices, options.mode), vjoy_buttons
        ):
            self._create_new_mapping(physical_button, vjoy_button)
        for physical_hat, vjoy_hat in zip(
            self._iter_physical_hats(input_devices, options.mode), vjoy_hats
        ):
            self._create_new_mapping(physical_hat, vjoy_hat)
        return self._create_mappings_report()

    def _get_used_vjoy_inputs(self, mode: str) -> list[types.VjoyInput]:
        used_vjoy_inputs = []
        connected_device_uuids = [
            dev.device_guid.uuid for dev in device_initialization.physical_devices()
        ]
        for device_uuid, input_items in self._profile.inputs.items():
            if device_uuid not in connected_device_uuids:
                continue
            for input_item in input_items:
                if input_item.mode != mode:
                    continue
                for binding in input_item.action_sequences:
                    assert isinstance(binding.root_action, root.RootData)
                    for child_action in binding.root_action.children:
                        if isinstance(child_action, map_to_vjoy.MapToVjoyData):
                            used_vjoy_inputs.append(
                                types.VjoyInput(
                                    child_action.vjoy_device_id,
                                    child_action.vjoy_input_type,
                                    child_action.vjoy_input_id,
                                )
                            )
        return used_vjoy_inputs

    def _iter_unused_vjoy_axes(
        self, vjoy_ids: list[int], used_vjoy_inputs: set[types.VjoyInput]
    ) -> Iterable[types.VjoyInput]:
        for vjoy_dev in device_initialization.vjoy_devices():
            if vjoy_dev.vjoy_id not in vjoy_ids:
                continue
            for linear_index in range(vjoy_dev.axis_count):
                axis_index = vjoy_dev.axis_map[linear_index].axis_index
                vjoy_axis = types.VjoyInput(
                    vjoy_dev.vjoy_id, types.InputType.JoystickAxis, axis_index
                )
                if vjoy_axis not in used_vjoy_inputs:
                    yield vjoy_axis

    def _iter_unused_vjoy_buttons(
        self, vjoy_ids: list[int], used_vjoy_inputs: set[types.VjoyInput]
    ) -> Iterable[types.VjoyInput]:
        for vjoy_dev in device_initialization.vjoy_devices():
            if vjoy_dev.vjoy_id not in vjoy_ids:
                continue
            for button_id in range(1, vjoy_dev.button_count + 1):
                vjoy_button = types.VjoyInput(
                    vjoy_dev.vjoy_id, types.InputType.JoystickButton, button_id
                )
                if vjoy_button not in used_vjoy_inputs:
                    yield vjoy_button

    def _iter_unused_vjoy_hats(
        self, vjoy_ids: list[int], used_vjoy_inputs: set[types.VjoyInput]
    ) -> Iterable[types.VjoyInput]:
        for vjoy_dev in device_initialization.vjoy_devices():
            if vjoy_dev.vjoy_id not in vjoy_ids:
                continue
            for hat_id in range(1, vjoy_dev.hat_count + 1):
                vjoy_hat = types.VjoyInput(
                    vjoy_dev.vjoy_id, types.InputType.JoystickHat, hat_id
                )
                if vjoy_hat not in used_vjoy_inputs:
                    yield vjoy_hat

    def _create_new_mapping(
        self,
        physical_input: profile.InputItem,
        vjoy_input: types.VjoyInput
    ) -> None:
        vjoy_action = plugin_manager.PluginManager().create_instance(
            map_to_vjoy.MapToVjoyData.name, physical_input.input_type
        )
        vjoy_action.vjoy_device_id = vjoy_input.vjoy_id
        vjoy_action.vjoy_input_id = vjoy_input.input_id
        vjoy_action.vjoy_input_type = vjoy_input.input_type
        binding = physical_input.add_item_binding()
        binding.root_action.insert_action(vjoy_action, "children")
        self._created_mappings.append(vjoy_action)

    def _create_mappings_report(self) -> str:
        return self._tr(
            "Created {created} mappings, retained {retained} previous bindings."
        ).format(
            created=len(self._created_mappings),
            retained=self._num_retained_bindings
        )


class Xbox360AutoMapper(_BaseAutoMapper):

    """Generates a standard Xbox 360 controller layout."""

    AXIS_TARGETS = [
        "left-thumb-x",
        "left-thumb-y",
        "right-thumb-x",
        "right-thumb-y",
        "left-trigger",
        "right-trigger",
    ]
    BUTTON_TARGETS = [
        "a",
        "b",
        "x",
        "y",
        "left-shoulder",
        "right-shoulder",
        "back",
        "start",
        "left-thumb",
        "right-thumb",
        "guide",
        "dpad-up",
        "dpad-down",
        "dpad-left",
        "dpad-right",
    ]

    def __init__(self, profile_data: profile.Profile) -> None:
        super().__init__(profile_data)
        self._created_mappings: list[map_to_xbox360.MapToXbox360Data] = []
        self._num_skipped_inputs = 0

    def generate_mappings(
        self,
        input_devices_guids: List[dill.GUID],
        options: XboxAutoMapperOptions,
    ) -> str:
        if not input_devices_guids:
            return self._tr("No input devices selected")

        input_devices = [
            dev
            for dev in device_initialization.physical_devices()
            if dev.device_guid in input_devices_guids
        ]

        self._prepare_profile(input_devices, options.overwrite_used_inputs)
        self._num_retained_bindings = 0
        self._num_skipped_inputs = 0

        physical_axes = list(self._iter_physical_axes(input_devices, options.mode))
        physical_buttons = list(
            self._iter_physical_buttons(input_devices, options.mode)
        )
        physical_hats = list(self._iter_physical_hats(input_devices, options.mode))

        for physical_axis, target in zip(physical_axes, self.AXIS_TARGETS):
            self._create_new_mapping(physical_axis, target, options.controller_id)
        self._num_skipped_inputs += max(0, len(physical_axes) - len(self.AXIS_TARGETS))

        button_targets = list(self.BUTTON_TARGETS)
        if physical_hats:
            button_targets = [
                target for target in button_targets if not target.startswith("dpad-")
            ]

        for physical_button, target in zip(physical_buttons, button_targets):
            self._create_new_mapping(physical_button, target, options.controller_id)
        self._num_skipped_inputs += max(0, len(physical_buttons) - len(button_targets))

        if physical_hats:
            self._create_new_mapping(physical_hats[0], "dpad", options.controller_id)
            self._num_skipped_inputs += max(0, len(physical_hats) - 1)

        return self._create_mappings_report(options.controller_id)

    def _create_new_mapping(
        self,
        physical_input: profile.InputItem,
        target: str,
        controller_id: int
    ) -> None:
        xbox_action = plugin_manager.PluginManager().create_instance(
            map_to_xbox360.MapToXbox360Data.name, physical_input.input_type
        )
        xbox_action.controller_id = controller_id
        xbox_action.target = target
        binding = physical_input.add_item_binding()
        binding.root_action.insert_action(xbox_action, "children")
        self._created_mappings.append(xbox_action)

    def _create_mappings_report(self, controller_id: int) -> str:
        return self._tr(
            "Created {created} Xbox 360 mappings for controller {controller}, retained {retained} previous bindings, skipped {skipped} inputs beyond the standard layout."
        ).format(
            created=len(self._created_mappings),
            controller=controller_id,
            retained=self._num_retained_bindings,
            skipped=self._num_skipped_inputs
        )
