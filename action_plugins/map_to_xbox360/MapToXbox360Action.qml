// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal
import QtQuick.Layouts

import Gremlin.ActionPlugins
import "../../qml"


Item {
    id: _root

    property MapToXbox360Model action

    implicitHeight: _content.height

    RowLayout {
        id: _content

        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            text: qsTr("Controller")
            anchors.verticalCenter: parent.verticalCenter
        }

        SpinBox {
            from: 1
            to: 4
            value: _root.action.controllerId

            onValueModified: {
                _root.action.controllerId = value
            }
        }

        Label {
            text: qsTr("Output")
            anchors.verticalCenter: parent.verticalCenter
        }

        ComboBox {
            id: _targetCombo

            model: _root.action.targetOptions
            textRole: "text"
            valueRole: "value"
            implicitContentWidthPolicy: ComboBox.WidestText
            enabled: !_root.action.isHatInput

            onActivated: {
                _root.action.target = currentValue
            }

            Component.onCompleted: {
                currentIndex = indexOfValue(_root.action.target)
            }

            Connections {
                target: _root.action

                function onChanged() {
                    _targetCombo.currentIndex = _targetCombo.indexOfValue(
                        _root.action.target
                    )
                }
            }
        }

        Label {
            visible: _root.action.isHatInput
            text: qsTr("Hat inputs map to the Xbox D-Pad.")
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }
    }
}
