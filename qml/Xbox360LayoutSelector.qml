// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal
import QtQuick.Layouts

import Gremlin.Style


Item {
    id: _root

    property var targetModel: []
    property string currentValue: ""
    property bool hatOnly: false
    signal targetSelected(string value)

    implicitWidth: 620
    implicitHeight: 290

    function hasTarget(value) {
        for (let i = 0; i < targetModel.length; i++) {
            if (targetModel[i].value === value) {
                return true
            }
        }
        return false
    }

    function labelFor(value, fallback) {
        for (let i = 0; i < targetModel.length; i++) {
            if (targetModel[i].value === value) {
                return targetModel[i].text
            }
        }
        return fallback
    }

    function targetColor(value) {
        return currentValue === value ? Style.accent : Style.backgroundShade
    }

    function targetBorder(value) {
        return currentValue === value ? Qt.lighter(Style.accent, 1.25) : Style.medColor
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Qt.tint(Style.background, "#18000000")
        border.width: 1
        border.color: Style.medColor
    }

    Rectangle {
        x: 148
        y: 70
        width: 324
        height: 156
        radius: 72
        color: Qt.tint(Style.backgroundShade, "#20000000")
        border.width: 1
        border.color: Style.medColor
    }

    Rectangle {
        x: 96
        y: 98
        width: 100
        height: 96
        radius: 42
        color: Qt.tint(Style.backgroundShade, "#12000000")
        border.width: 1
        border.color: Style.medColor
        rotation: -12
    }

    Rectangle {
        x: 424
        y: 98
        width: 100
        height: 96
        radius: 42
        color: Qt.tint(Style.backgroundShade, "#12000000")
        border.width: 1
        border.color: Style.medColor
        rotation: 12
    }

    Rectangle {
        x: 150
        y: 26
        width: 130
        height: 30
        radius: 14
        visible: _root.hasTarget("left-trigger") || _root.hasTarget("left-shoulder")
        color: Qt.tint(Style.backgroundShade, "#20000000")
        border.width: 1
        border.color: Style.medColor
    }

    Rectangle {
        x: 340
        y: 26
        width: 130
        height: 30
        radius: 14
        visible: _root.hasTarget("right-trigger") || _root.hasTarget("right-shoulder")
        color: Qt.tint(Style.backgroundShade, "#20000000")
        border.width: 1
        border.color: Style.medColor
    }

    Item {
        x: 163
        y: 31
        width: 104
        height: 22
        visible: _root.hasTarget("left-trigger")

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: _root.targetColor("left-trigger")
            border.width: 2
            border.color: _root.targetBorder("left-trigger")
        }

        Label {
            anchors.centerIn: parent
            text: "LT"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: _root.targetSelected("left-trigger")
        }
    }

    Item {
        x: 353
        y: 31
        width: 104
        height: 22
        visible: _root.hasTarget("right-trigger")

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: _root.targetColor("right-trigger")
            border.width: 2
            border.color: _root.targetBorder("right-trigger")
        }

        Label {
            anchors.centerIn: parent
            text: "RT"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: _root.targetSelected("right-trigger")
        }
    }

    Item {
        x: 158
        y: 62
        width: 114
        height: 22
        visible: _root.hasTarget("left-shoulder")

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: _root.targetColor("left-shoulder")
            border.width: 2
            border.color: _root.targetBorder("left-shoulder")
        }

        Label {
            anchors.centerIn: parent
            text: "LB"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: _root.targetSelected("left-shoulder")
        }
    }

    Item {
        x: 348
        y: 62
        width: 114
        height: 22
        visible: _root.hasTarget("right-shoulder")

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: _root.targetColor("right-shoulder")
            border.width: 2
            border.color: _root.targetBorder("right-shoulder")
        }

        Label {
            anchors.centerIn: parent
            text: "RB"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: _root.targetSelected("right-shoulder")
        }
    }

    Item {
        x: 190
        y: 125
        width: 86
        height: 86
        visible: _root.hasTarget("left-thumb-x") || _root.hasTarget("left-thumb-y") || _root.hasTarget("left-thumb")

        Rectangle {
            anchors.fill: parent
            radius: 43
            color: _root.currentValue === "left-thumb" ? _root.targetColor("left-thumb") : Qt.tint(Style.backgroundShade, "#35000000")
            border.width: 2
            border.color: _root.currentValue === "left-thumb" ? _root.targetBorder("left-thumb") : Style.medColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: 34
            height: 34
            radius: 17
            color: (_root.currentValue === "left-thumb-x" || _root.currentValue === "left-thumb-y") ? Style.accent : Style.background
            border.width: 2
            border.color: (_root.currentValue === "left-thumb-x" || _root.currentValue === "left-thumb-y") ? Qt.lighter(Style.accent, 1.25) : Style.medColor
        }

        Label {
            anchors.centerIn: parent
            text: _root.hasTarget("left-thumb-x") || _root.hasTarget("left-thumb-y") ? "L" : ""
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: {
                if (_root.hasTarget("left-thumb")) {
                    _root.targetSelected("left-thumb")
                } else if (_root.hasTarget("left-thumb-x")) {
                    _root.targetSelected("left-thumb-x")
                }
            }
        }
    }

    Item {
        x: 368
        y: 154
        width: 82
        height: 82
        visible: _root.hasTarget("right-thumb-x") || _root.hasTarget("right-thumb-y") || _root.hasTarget("right-thumb")

        Rectangle {
            anchors.fill: parent
            radius: 41
            color: _root.currentValue === "right-thumb" ? _root.targetColor("right-thumb") : Qt.tint(Style.backgroundShade, "#35000000")
            border.width: 2
            border.color: _root.currentValue === "right-thumb" ? _root.targetBorder("right-thumb") : Style.medColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: 32
            height: 32
            radius: 16
            color: (_root.currentValue === "right-thumb-x" || _root.currentValue === "right-thumb-y") ? Style.accent : Style.background
            border.width: 2
            border.color: (_root.currentValue === "right-thumb-x" || _root.currentValue === "right-thumb-y") ? Qt.lighter(Style.accent, 1.25) : Style.medColor
        }

        Label {
            anchors.centerIn: parent
            text: _root.hasTarget("right-thumb-x") || _root.hasTarget("right-thumb-y") ? "R" : ""
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            enabled: !hatOnly
            onClicked: {
                if (_root.hasTarget("right-thumb")) {
                    _root.targetSelected("right-thumb")
                } else if (_root.hasTarget("right-thumb-x")) {
                    _root.targetSelected("right-thumb-x")
                }
            }
        }
    }

    Item {
        x: 124
        y: 150
        width: 78
        height: 78
        visible: _root.hasTarget("dpad") || _root.hasTarget("dpad-up")

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Qt.tint(Style.backgroundShade, "#25000000")
            border.width: 1
            border.color: Style.medColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: 22
            height: 66
            radius: 8
            color: _root.currentValue === "dpad" ? _root.targetColor("dpad") : Qt.tint(Style.background, "#30000000")
        }

        Rectangle {
            anchors.centerIn: parent
            width: 66
            height: 22
            radius: 8
            color: _root.currentValue === "dpad" ? _root.targetColor("dpad") : Qt.tint(Style.background, "#30000000")
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (_root.hasTarget("dpad")) {
                    _root.targetSelected("dpad")
                } else if (_root.hasTarget("dpad-up")) {
                    _root.targetSelected("dpad-up")
                }
            }
        }
    }

    Repeater {
        model: [
            { value: "y", text: "Y", x: 475, y: 121, radius: 22 },
            { value: "x", text: "X", x: 445, y: 151, radius: 22 },
            { value: "b", text: "B", x: 505, y: 151, radius: 22 },
            { value: "a", text: "A", x: 475, y: 181, radius: 22 }
        ]

        delegate: Item {
            x: modelData.x
            y: modelData.y
            width: modelData.radius * 2
            height: modelData.radius * 2
            visible: _root.hasTarget(modelData.value)

            Rectangle {
                anchors.fill: parent
                radius: modelData.radius
                color: _root.targetColor(modelData.value)
                border.width: 2
                border.color: _root.targetBorder(modelData.value)
            }

            Label {
                anchors.centerIn: parent
                text: modelData.text
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                enabled: !hatOnly
                onClicked: _root.targetSelected(modelData.value)
            }
        }
    }

    Repeater {
        model: [
            { value: "back", text: "Back", x: 245, y: 114, w: 50, h: 24 },
            { value: "guide", text: "Guide", x: 293, y: 93, w: 34, h: 34 },
            { value: "start", text: "Start", x: 328, y: 114, w: 50, h: 24 }
        ]

        delegate: Item {
            x: modelData.x
            y: modelData.y
            width: modelData.w
            height: modelData.h
            visible: _root.hasTarget(modelData.value)

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: _root.targetColor(modelData.value)
                border.width: 2
                border.color: _root.targetBorder(modelData.value)
            }

            Label {
                anchors.centerIn: parent
                text: modelData.text
                font.pixelSize: modelData.value === "guide" ? 10 : 9
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                enabled: !hatOnly
                onClicked: _root.targetSelected(modelData.value)
            }
        }
    }

    Repeater {
        model: [
            { value: "left-thumb-x", text: "LX", x: 178, y: 218, w: 38, h: 20 },
            { value: "left-thumb-y", text: "LY", x: 250, y: 218, w: 38, h: 20 },
            { value: "right-thumb-x", text: "RX", x: 355, y: 238, w: 38, h: 20 },
            { value: "right-thumb-y", text: "RY", x: 427, y: 238, w: 38, h: 20 }
        ]

        delegate: Item {
            x: modelData.x
            y: modelData.y
            width: modelData.w
            height: modelData.h
            visible: _root.hasTarget(modelData.value)

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: _root.targetColor(modelData.value)
                border.width: 2
                border.color: _root.targetBorder(modelData.value)
            }

            Label {
                anchors.centerIn: parent
                text: modelData.text
                font.pixelSize: 10
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                enabled: !hatOnly
                onClicked: _root.targetSelected(modelData.value)
            }
        }
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        text: hatOnly
            ? qsTr("Click the D-Pad area to bind this hat input.")
            : qsTr("Click a control on the gamepad diagram to choose the Xbox target.")
        color: Style.foreground
    }
}
