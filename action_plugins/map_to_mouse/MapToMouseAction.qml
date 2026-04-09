// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import QtQuick.Controls.Universal

import Gremlin.Profile
import Gremlin.ActionPlugins
import "../../qml"


Item {
    id: _root

    property MapToMouseModel action

    property int limitLow: 0
    property int limitHigh: 100000

    implicitHeight: _content.height

    ColumnLayout {
        id: _content

        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
            Label {
                id: _label

                Layout.preferredWidth: 50

                text: qsTr("<B>Mode</B>")
            }

            // Radio buttons to select the desired mapping mode
            RadioButton {
                id: _mode_button

                text: qsTr("Button")
                visible: inputBinding.behavior === "button"

                checked: _root.action.mode === "Button"
                onClicked: () => { _root.action.mode = "Button" }
            }

            RadioButton {
                id: _mode_motion

                Layout.fillWidth: true

                text: qsTr("Motion")

                checked: _root.action.mode === "Motion"
                onClicked: () => { _root.action.mode = "Motion" }
            }
        }

        // Button configuration
        RowLayout {
            visible: _mode_button.checked

            Label {
                text: qsTr("Mouse Button")
            }

            InputListener {
                callback: (inputs) => { _root.action.updateInputs(inputs) }
                multipleInputs: false
                eventTypes: ["mouse"]

                buttonLabel: _root.action.button
            }

        }

        // Motion configuration for button-like inputs
        GridLayout {
            visible: _mode_motion.checked && inputBinding.behavior === "button"

            columns: 5

            Label {
                Layout.fillWidth: true

                text: qsTr("Minimum speed")
            }

            JGSpinBox {
                id: _min_speed_button

                Layout.fillWidth: true

                value: _root.action.minSpeed
                from: limitLow
                to: _max_speed_button.value

                onValueModified: function() {
                    _root.action.minSpeed = value
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }

            Label {
                Layout.fillWidth: true

                text: qsTr("Maximum speed")
            }

            JGSpinBox {
                id: _max_speed_button

                Layout.fillWidth: true

                value: _root.action.maxSpeed
                from: _min_speed_button.value
                to: limitHigh

                onValueModified: function() {
                    _root.action.maxSpeed = value
                }
            }

            Label {
                text: qsTr("Time to maximum speed")
            }

            FloatSpinBox {
                minValue: 0
                maxValue: 60
                value: _root.action.timeToMaxSpeed
                stepSize: 1.0
                decimals: 1

                onValueModified: (newValue) => {
                    _root.action.timeToMaxSpeed = newValue
                }
            }

            Rectangle {}

            Label {
                text: qsTr("Direction")
            }

            JGSpinBox {
                value: _root.action.direction
                from: 0
                to: 360
                stepSize: 15

                onValueModified: function() {
                    _root.action.direction = value
                }
            }
        }

        // Motion configuration for axis inputs
        ColumnLayout {
            visible: _mode_motion.checked && inputBinding.behavior === "axis"

            RowLayout {
                Label {
                    text: qsTr("Control motion of")
                }

                RadioButton {
                    text: qsTr("X Axis")

                    checked: _root.action.direction === 90
                    onClicked: () => { _root.action.direction = 90 }
                }

                RadioButton {
                    text: qsTr("Y Axis")

                    checked: _root.action.direction === 0
                    onClicked: () => { _root.action.direction = 0 }
                }
            }

            RowLayout {

                Label {
                    Layout.rightMargin: 10

                    text: qsTr("Minimum speed")
                }

                JGSpinBox {
                    id: _min_speed_axis

                    Layout.preferredWidth: 150

                    value: _root.action.minSpeed
                    from: limitLow
                    to: _max_speed_axis.value

                    onValueModified: () => { _root.action.minSpeed = value }
                }

                Label {
                    Layout.leftMargin: 50
                    Layout.rightMargin: 10

                    text: qsTr("Maximum speed")
                }

                JGSpinBox {
                    id: _max_speed_axis

                    Layout.preferredWidth: 150

                    value: _root.action.maxSpeed
                    from: _min_speed_axis.value
                    to: limitHigh

                    onValueModified: () => { _root.action.maxSpeed = value }
                }
            }
        }

        // Motion configuration for hat inputs
        GridLayout {
            visible: _mode_motion.checked && inputBinding.behavior === "hat"

            columns: 4

            Label {
                Layout.fillWidth: true

                text: qsTr("Minimum speed")
            }

            JGSpinBox {
                id: _min_speed_hat

                Layout.fillWidth: true

                value: _root.action.minSpeed
                from: limitLow
                to: _max_speed_hat.value

                onValueModified: function() {
                    _root.action.minSpeed = value
                }
            }

            Label {
                Layout.fillWidth: true

                text: qsTr("Maximum speed")
            }

            JGSpinBox {
                id: _max_speed_hat

                Layout.fillWidth: true

                value: _root.action.maxSpeed
                from: _min_speed_hat.value
                to: limitHigh

                onValueModified: function() {
                    _root.action.maxSpeed = value
                }
            }

            Label {
                text: qsTr("Time to maximum speed")
            }

            FloatSpinBox {
                minValue: 0
                maxValue: 30
                value: _root.action.timeToMaxSpeed
                stepSize: 1.0
                decimals: 1

                onValueModified: (newValue) => {
                    _root.action.timeToMaxSpeed = newValue
                }
            }
        }
    }
}
