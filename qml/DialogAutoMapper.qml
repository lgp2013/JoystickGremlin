// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal
import QtQuick.Layouts
import QtQuick.Window

import Gremlin.Device
import Gremlin.Profile
import Gremlin.Tools
import Gremlin.Style

Window {
    minimumWidth: 980
    minimumHeight: 540

    color: Style.background
    Universal.theme: Style.theme

    title: qsTr("Auto Mapper")

    DeviceListModel {
        id: _physicalDevices
        deviceType: "physical"
    }

    DeviceListModel {
        id: _virtualDevices
        deviceType: "virtual"
    }

    Tools {
        id: tools
    }

    property var selectedPhysicalDevices: ({})
    property var selectedVJoyDevices: ({})
    property var outputTargets: [
        { value: "vjoy", text: qsTr("vJoy") },
        { value: "xbox360", text: qsTr("Xbox 360") }
    ]
    property string selectedOutputTarget: "vjoy"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Label {
                text: qsTr("Target Type")
            }

            ComboBox {
                id: _targetSelector
                model: outputTargets
                textRole: "text"
                valueRole: "value"

                onActivated: {
                    selectedOutputTarget = currentValue
                }

                Component.onCompleted: {
                    currentIndex = indexOfValue(selectedOutputTarget)
                }
            }

            Label {
                visible: selectedOutputTarget === "xbox360"
                text: qsTr("Xbox 360 Controller")
            }

            SpinBox {
                id: _controllerSelector
                visible: selectedOutputTarget === "xbox360"
                from: 1
                to: 4
                value: 1
            }

            LayoutHorizontalSpacer {}
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: 4

                RowLayout {
                    Label {
                        text: qsTr("Physical Devices")
                    }

                    LayoutHorizontalSpacer {
                        Layout.preferredHeight: 1
                        color: Style.accent
                    }
                }

                JGListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: _physicalDevices
                    scrollbarAlwaysVisible: true

                    delegate: CheckBox {
                        width: ListView.view.width - 10
                        text: model.name
                        checked: !!selectedPhysicalDevices[model.guid]

                        onCheckedChanged: {
                            selectedPhysicalDevices[model.guid] = checked
                        }
                    }
                }
            }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: selectedOutputTarget === "vjoy"
                    ? _vjoyTargets
                    : _xboxTargets
            }
        }

        RowLayout {
            Label {
                text: qsTr("Select Mode")
            }

            ComboBox {
                id: _modeSelector
                model: ModeListModel {}
                textRole: "name"
            }

            LayoutHorizontalSpacer {}

            Switch {
                id: _overwriteNonEmpty
                text: qsTr("Overwrite non-empty physical inputs")
            }

            Switch {
                id: _repeatDevices
                visible: selectedOutputTarget === "vjoy"
                text: qsTr("Repeat vJoy devices")
            }
        }

        RowLayout {
            Layout.topMargin: 6

            Button {
                text: selectedOutputTarget === "vjoy"
                    ? qsTr("Create 1:1 mappings")
                    : qsTr("Create Xbox 360 mappings")

                onClicked: {
                    if (selectedOutputTarget === "vjoy") {
                        _statusMessage.text = tools.createMappings(
                            _modeSelector.currentText,
                            selectedPhysicalDevices,
                            selectedVJoyDevices,
                            _overwriteNonEmpty.checked,
                            _repeatDevices.checked
                        )
                    } else {
                        _statusMessage.text = tools.createXbox360Mappings(
                            _modeSelector.currentText,
                            selectedPhysicalDevices,
                            _controllerSelector.value,
                            _overwriteNonEmpty.checked
                        )
                    }

                    selectedPhysicalDevices = ({})
                    selectedVJoyDevices = ({})
                }
            }

            Label {
                id: _statusMessage

                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                wrapMode: Text.Wrap

                text: selectedOutputTarget === "vjoy"
                    ? qsTr("Select devices, options and then click the button.")
                    : qsTr("Select devices, choose the Xbox controller number, and then click the button.")
            }

            IconButton {
                text: bsi.icons.help
                font.pixelSize: 24

                ToolTip {
                    text: selectedOutputTarget === "vjoy"
                        ? qsTr("- Select mode to create bindings in.\n- Select source physical devices and target vJoy devices.\n- Click \"Create 1:1 mappings\" button.\n\nOverwrite non-empty: Replaces existing mappings in the profile.\nRepeat vJoy: Cycles through vJoy inputs, if needed to map all physical inputs.")
                        : qsTr("- Select mode to create bindings in.\n- Select source physical devices.\n- Choose the target Xbox 360 controller number.\n- Click \"Create Xbox 360 mappings\".\n\nXbox mapping order:\nAxes -> LX, LY, RX, RY, LT, RT\nButtons -> A, B, X, Y, LB, RB, Back, Start, LS, RS, Guide\nFirst hat -> D-Pad\nExtra inputs beyond the standard layout are skipped.")

                    visible: parent.hovered
                    delay: 500
                }
            }
        }
    }

    Component {
        id: _vjoyTargets

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                Label {
                    text: qsTr("vJoy Devices")
                }

                LayoutHorizontalSpacer {
                    Layout.preferredHeight: 1
                    color: Style.accent
                }
            }

            JGListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: _virtualDevices
                scrollbarAlwaysVisible: true

                delegate: CheckBox {
                    width: ListView.view.width - 10
                    text: model.name
                    checked: !!selectedVJoyDevices[model.vjoy_id]

                    onCheckedChanged: {
                        selectedVJoyDevices[model.vjoy_id] = checked
                    }
                }
            }
        }
    }

    Component {
        id: _xboxTargets

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Label {
                    text: qsTr("Standard Layout")
                }

                LayoutHorizontalSpacer {
                    Layout.preferredHeight: 1
                    color: Style.accent
                }
            }

            Xbox360LayoutSelector {
                Layout.fillWidth: true
                targetModel: [
                    { value: "left-thumb-x", text: "LX" },
                    { value: "left-thumb-y", text: "LY" },
                    { value: "right-thumb-x", text: "RX" },
                    { value: "right-thumb-y", text: "RY" },
                    { value: "left-trigger", text: "LT" },
                    { value: "right-trigger", text: "RT" },
                    { value: "left-shoulder", text: "LB" },
                    { value: "right-shoulder", text: "RB" },
                    { value: "back", text: "Back" },
                    { value: "start", text: "Start" },
                    { value: "guide", text: "Guide" },
                    { value: "left-thumb", text: "LS" },
                    { value: "right-thumb", text: "RS" },
                    { value: "x", text: "X" },
                    { value: "y", text: "Y" },
                    { value: "a", text: "A" },
                    { value: "b", text: "B" },
                    { value: "dpad", text: "D-Pad" }
                ]
                currentValue: "a"
                enabled: false
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: Qt.tint(Style.backgroundShade, "#22000000")
                border.width: 1
                border.color: Style.medColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: qsTr("Wizard Rules")
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: qsTr("The wizard maps the first six free physical axes to LX, LY, RX, RY, LT and RT. It then maps free buttons to A, B, X, Y, LB, RB, Back, Start, LS, RS and Guide. If a hat exists, the first hat becomes the Xbox D-Pad. Extra inputs beyond the standard Xbox layout are skipped and reported.")
                    }
                }
            }
        }
    }
}
