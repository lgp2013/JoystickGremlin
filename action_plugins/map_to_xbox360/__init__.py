# -*- coding: utf-8; -*-
#
# SPDX-License-Identifier: GPL-3.0-only

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, List, override
from xml.etree import ElementTree

from PySide6 import QtCore

from gremlin import device_helpers, error, event_handler, signal, util
from gremlin.base_classes import (
    AbstractActionData,
    AbstractFunctor,
    UserFeedback,
    Value,
)
from gremlin.profile import Library
from gremlin.types import ActionProperty, HatDirection, InputType, PropertyType
from gremlin.ui.action_model import ActionModel, SequenceIndex
from gremlin.xbox_output import XboxOutputManager

if TYPE_CHECKING:
    from gremlin.ui.profile import InputItemBindingModel


@dataclass(frozen=True)
class XboxTarget:

    value: str
    label: str


AXIS_TARGETS = (
    XboxTarget("left-thumb-x", "Left Stick X"),
    XboxTarget("left-thumb-y", "Left Stick Y"),
    XboxTarget("right-thumb-x", "Right Stick X"),
    XboxTarget("right-thumb-y", "Right Stick Y"),
    XboxTarget("left-trigger", "Left Trigger"),
    XboxTarget("right-trigger", "Right Trigger"),
)

BUTTON_TARGETS = (
    XboxTarget("a", "A Button"),
    XboxTarget("b", "B Button"),
    XboxTarget("x", "X Button"),
    XboxTarget("y", "Y Button"),
    XboxTarget("left-shoulder", "Left Bumper"),
    XboxTarget("right-shoulder", "Right Bumper"),
    XboxTarget("back", "Back"),
    XboxTarget("start", "Start"),
    XboxTarget("guide", "Guide"),
    XboxTarget("left-thumb", "Left Stick Click"),
    XboxTarget("right-thumb", "Right Stick Click"),
    XboxTarget("dpad-up", "D-Pad Up"),
    XboxTarget("dpad-down", "D-Pad Down"),
    XboxTarget("dpad-left", "D-Pad Left"),
    XboxTarget("dpad-right", "D-Pad Right"),
)

HAT_TARGETS = (
    XboxTarget("dpad", "D-Pad"),
)


class MapToXbox360Functor(AbstractFunctor):

    def __init__(self, action: MapToXbox360Data) -> None:
        super().__init__(action)
        self._manager = XboxOutputManager()

    @override
    def __call__(
        self,
        event: event_handler.Event,
        value: Value,
        properties: list[ActionProperty]=[]
    ) -> None:
        if not self._should_execute(value):
            return

        if self.data.output_type == "axis":
            self._manager.set_axis(
                self.data.controller_id,
                self.data.target,
                value.current
            )
        elif self.data.output_type == "button":
            self._manager.set_button(
                self.data.controller_id,
                self.data.target,
                value.current
            )

            if value.current and ActionProperty.DisableAutoRelease not in properties:
                device_helpers.ButtonReleaseActions().register_callback(
                    lambda: self._manager.set_button(
                        self.data.controller_id,
                        self.data.target,
                        False
                    ),
                    event
                )
        elif self.data.output_type == "hat":
            self._manager.set_hat(self.data.controller_id, value.current)
        else:
            raise error.GremlinError(
                f"Unknown Xbox output type '{self.data.output_type}'."
            )


class MapToXbox360Model(ActionModel):

    changed = QtCore.Signal()

    def __init__(
        self,
        data: AbstractActionData,
        binding_model: InputItemBindingModel,
        action_index: SequenceIndex,
        parent_index: SequenceIndex,
        parent: QtCore.QObject
    ) -> None:
        super().__init__(data, binding_model, action_index, parent_index, parent)

    def _qml_path_impl(self) -> str:
        return "file:///" + QtCore.QFile(
            "core_plugins:map_to_xbox360/MapToXbox360Action.qml"
        ).fileName()

    def _action_behavior(self) -> str:
        return self._binding_model.get_action_model_by_sidx(
            self._parent_sequence_index.index
        ).actionBehavior

    def _get_controller_id(self) -> int:
        return self._data.controller_id

    def _set_controller_id(self, controller_id: int) -> None:
        controller_id = max(1, min(controller_id, 4))
        if controller_id != self._data.controller_id:
            self._data.controller_id = controller_id
            self.changed.emit()
            signal.signal.inputItemChanged.emit(
                self._binding_model.parent().enumeration_index
            )

    def _get_target(self) -> str:
        return self._data.target

    def _set_target(self, target: str) -> None:
        if target != self._data.target:
            self._data.target = target
            self.changed.emit()
            signal.signal.inputItemChanged.emit(
                self._binding_model.parent().enumeration_index
            )

    def _get_target_options(self) -> list[dict[str, str]]:
        return [
            {
                "value": entry.value,
                "text": QtCore.QCoreApplication.translate(
                    "MapToXbox360Targets",
                    entry.label
                )
            }
            for entry in self._data.valid_targets()
        ]

    @QtCore.Property(bool, notify=changed)
    def isAxisInput(self) -> bool:
        return self._data.output_type == "axis"

    @QtCore.Property(bool, notify=changed)
    def isHatInput(self) -> bool:
        return self._data.output_type == "hat"

    controllerId = QtCore.Property(
        int,
        fget=_get_controller_id,
        fset=_set_controller_id,
        notify=changed
    )

    target = QtCore.Property(
        str,
        fget=_get_target,
        fset=_set_target,
        notify=changed
    )

    targetOptions = QtCore.Property(
        list,
        fget=_get_target_options,
        notify=changed
    )


class MapToXbox360Data(AbstractActionData):

    version = 1
    name = "Map to Xbox 360"
    tag = "map-to-xbox360"
    icon = "\uF5DE"

    functor = MapToXbox360Functor
    model = MapToXbox360Model

    properties = (
        ActionProperty.ActivateOnBoth,
    )
    input_types = (
        InputType.JoystickAxis,
        InputType.JoystickButton,
        InputType.JoystickHat,
        InputType.Keyboard,
    )

    def __init__(
        self,
        behavior_type: InputType=InputType.JoystickButton
    ) -> None:
        super().__init__(behavior_type)
        self.controller_id = 1
        self.target = self._default_target(behavior_type)

    @classmethod
    @override
    def can_create(cls) -> bool:
        return XboxOutputManager.is_available()

    @property
    def output_type(self) -> str:
        if self.behavior_type == InputType.JoystickAxis:
            return "axis"
        if self.behavior_type == InputType.JoystickHat:
            return "hat"
        return "button"

    def valid_targets(self) -> tuple[XboxTarget, ...]:
        match self.output_type:
            case "axis":
                return AXIS_TARGETS
            case "hat":
                return HAT_TARGETS
            case _:
                return BUTTON_TARGETS

    @override
    def _from_xml(self, node: ElementTree.Element, library: Library) -> None:
        self._id = util.read_action_id(node)
        self.controller_id = util.read_property(
            node, "controller-id", PropertyType.Int
        )
        self.target = util.read_property(node, "target", PropertyType.String)

    @override
    def _to_xml(self) -> ElementTree.Element:
        node = util.create_action_node(MapToXbox360Data.tag, self._id)
        util.append_property_nodes(node, [
            ["controller-id", self.controller_id, PropertyType.Int],
            ["target", self.target, PropertyType.String],
        ])
        return node

    @override
    def user_feedback(self) -> List[UserFeedback]:
        feedback = []
        if not XboxOutputManager.is_available():
            feedback.append(UserFeedback(
                UserFeedback.FeedbackType.Error,
                "vgamepad is not installed."
            ))
        elif self.target not in [entry.value for entry in self.valid_targets()]:
            feedback.append(UserFeedback(
                UserFeedback.FeedbackType.Error,
                f"Target '{self.target}' is not valid for this input type."
            ))
        return feedback

    @override
    def _valid_selectors(self) -> List[str]:
        return []

    @override
    def _get_container(self, selector: str) -> List[AbstractActionData]:
        raise error.GremlinError(f"{self.name}: has no containers")

    @override
    def _handle_behavior_change(
        self,
        old_behavior: InputType,
        new_behavior: InputType
    ) -> None:
        valid_targets = [entry.value for entry in self.valid_targets()]
        if self.target not in valid_targets:
            self.target = self._default_target(new_behavior)

    def _default_target(self, behavior_type: InputType) -> str:
        if behavior_type == InputType.JoystickAxis:
            return AXIS_TARGETS[0].value
        if behavior_type == InputType.JoystickHat:
            return HAT_TARGETS[0].value
        return BUTTON_TARGETS[0].value


create = MapToXbox360Data
