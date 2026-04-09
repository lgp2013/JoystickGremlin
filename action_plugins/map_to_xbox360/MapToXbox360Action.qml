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

    implicitHeight: _content.implicitHeight

    ColumnLayout {
        id: _content

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Controller")
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
            }

            ComboBox {
                id: _targetCombo

                Layout.fillWidth: true
                model: _root.action.targetOptions
                textRole: "text"
                valueRole: "value"
                implicitContentWidthPolicy: ComboBox.WidestText

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
        }

        Xbox360LayoutSelector {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            targetModel: _root.action.targetOptions
            currentValue: _root.action.target
            hatOnly: _root.action.isHatInput

            onTargetSelected: (value) => {
                _root.action.target = value
            }
        }
    }
}
