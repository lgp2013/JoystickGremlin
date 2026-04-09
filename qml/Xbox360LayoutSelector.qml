// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

import Gremlin.Style


Item {
    id: _root

    property var targetModel: []
    property string currentValue: ""
    property bool hatOnly: false
    signal targetSelected(string value)

    implicitWidth: 660
    implicitHeight: 360

    function hasTarget(value) {
        for (let i = 0; i < targetModel.length; i++) {
            if (targetModel[i].value === value) {
                return true
            }
        }
        return false
    }

    function targetColor(value) {
        return currentValue === value
            ? Style.accent
            : Qt.tint(Style.background, "#20ffffff")
    }

    function targetBorder(value) {
        return currentValue === value
            ? Qt.lighter(Style.accent, 1.2)
            : Qt.tint(Style.medColor, "#60ffffff")
    }

    function faceButtonFill(value, fallback) {
        if (currentValue === value) {
            return Style.accent
        }
        return fallback
    }

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: Qt.tint(Style.background, "#14000000")
        border.width: 1
        border.color: Qt.tint(Style.medColor, "#80ffffff")
    }

    Rectangle {
        x: 94
        y: 24
        width: 472
        height: 74
        radius: 36
        color: Qt.tint(Style.backgroundShade, "#26ffffff")
        border.width: 1
        border.color: Qt.tint(Style.medColor, "#6fffffff")
    }

    Rectangle {
        x: 106
        y: 38
        width: 150
        height: 34
        radius: 16
        color: _root.hasTarget("left-trigger")
            ? _root.targetColor("left-trigger")
            : Qt.tint(Style.background, "#30ffffff")
        border.width: 2
        border.color: _root.hasTarget("left-trigger")
            ? _root.targetBorder("left-trigger")
            : Qt.tint(Style.medColor, "#70ffffff")
        visible: _root.hasTarget("left-trigger")
    }

    Label {
        x: 106
        y: 38
        width: 150
        height: 34
        text: "LT"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        visible: _root.hasTarget("left-trigger")
    }

    MouseArea {
        x: 106
        y: 38
        width: 150
        height: 34
        enabled: _root.hasTarget("left-trigger") && !hatOnly
        onClicked: _root.targetSelected("left-trigger")
    }

    Rectangle {
        x: 404
        y: 38
        width: 150
        height: 34
        radius: 16
        color: _root.hasTarget("right-trigger")
            ? _root.targetColor("right-trigger")
            : Qt.tint(Style.background, "#30ffffff")
        border.width: 2
        border.color: _root.hasTarget("right-trigger")
            ? _root.targetBorder("right-trigger")
            : Qt.tint(Style.medColor, "#70ffffff")
        visible: _root.hasTarget("right-trigger")
    }

    Label {
        x: 404
        y: 38
        width: 150
        height: 34
        text: "RT"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        visible: _root.hasTarget("right-trigger")
    }

    MouseArea {
        x: 404
        y: 38
        width: 150
        height: 34
        enabled: _root.hasTarget("right-trigger") && !hatOnly
        onClicked: _root.targetSelected("right-trigger")
    }

    Rectangle {
        x: 114
        y: 72
        width: 136
        height: 18
        radius: 9
        color: _root.hasTarget("left-shoulder")
            ? _root.targetColor("left-shoulder")
            : Qt.tint(Style.background, "#32ffffff")
        border.width: 2
        border.color: _root.hasTarget("left-shoulder")
            ? _root.targetBorder("left-shoulder")
            : Qt.tint(Style.medColor, "#70ffffff")
        visible: _root.hasTarget("left-shoulder")
    }

    Label {
        x: 114
        y: 72
        width: 136
        height: 18
        text: "LB"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 11
        font.bold: true
        visible: _root.hasTarget("left-shoulder")
    }

    MouseArea {
        x: 114
        y: 72
        width: 136
        height: 18
        enabled: _root.hasTarget("left-shoulder") && !hatOnly
        onClicked: _root.targetSelected("left-shoulder")
    }

    Rectangle {
        x: 410
        y: 72
        width: 136
        height: 18
        radius: 9
        color: _root.hasTarget("right-shoulder")
            ? _root.targetColor("right-shoulder")
            : Qt.tint(Style.background, "#32ffffff")
        border.width: 2
        border.color: _root.hasTarget("right-shoulder")
            ? _root.targetBorder("right-shoulder")
            : Qt.tint(Style.medColor, "#70ffffff")
        visible: _root.hasTarget("right-shoulder")
    }

    Label {
        x: 410
        y: 72
        width: 136
        height: 18
        text: "RB"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 11
        font.bold: true
        visible: _root.hasTarget("right-shoulder")
    }

    MouseArea {
        x: 410
        y: 72
        width: 136
        height: 18
        enabled: _root.hasTarget("right-shoulder") && !hatOnly
        onClicked: _root.targetSelected("right-shoulder")
    }

    Canvas {
        id: _shell
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: _hint.top
        anchors.leftMargin: 38
        anchors.rightMargin: 38
        anchors.topMargin: 84
        anchors.bottomMargin: 14

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const w = width
            const h = height

            const grad = ctx.createLinearGradient(0, 0, 0, h)
            grad.addColorStop(0.0, Qt.tint(Style.backgroundShade, "#78ffffff"))
            grad.addColorStop(0.28, Qt.tint(Style.background, "#22ffffff"))
            grad.addColorStop(0.6, Qt.tint(Style.backgroundShade, "#12ffffff"))
            grad.addColorStop(1.0, Qt.tint(Style.background, "#00000000"))

            ctx.fillStyle = grad
            ctx.strokeStyle = Qt.tint(Style.medColor, "#82ffffff")
            ctx.lineWidth = 2

            ctx.beginPath()
            ctx.moveTo(w * 0.31, h * 0.14)
            ctx.bezierCurveTo(w * 0.23, h * 0.16, w * 0.16, h * 0.22, w * 0.12, h * 0.34)
            ctx.bezierCurveTo(w * 0.06, h * 0.5, w * 0.07, h * 0.72, w * 0.16, h * 0.88)
            ctx.bezierCurveTo(w * 0.22, h * 0.98, w * 0.34, h * 1.02, w * 0.43, h * 0.86)
            ctx.bezierCurveTo(w * 0.47, h * 0.79, w * 0.53, h * 0.79, w * 0.57, h * 0.86)
            ctx.bezierCurveTo(w * 0.66, h * 1.02, w * 0.78, h * 0.98, w * 0.84, h * 0.88)
            ctx.bezierCurveTo(w * 0.93, h * 0.72, w * 0.94, h * 0.5, w * 0.88, h * 0.34)
            ctx.bezierCurveTo(w * 0.84, h * 0.22, w * 0.77, h * 0.16, w * 0.69, h * 0.14)
            ctx.bezierCurveTo(w * 0.63, h * 0.12, w * 0.58, h * 0.14, w * 0.54, h * 0.2)
            ctx.bezierCurveTo(w * 0.51, h * 0.25, w * 0.49, h * 0.25, w * 0.46, h * 0.2)
            ctx.bezierCurveTo(w * 0.42, h * 0.14, w * 0.37, h * 0.12, w * 0.31, h * 0.14)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()

            ctx.beginPath()
            ctx.strokeStyle = Qt.tint(Style.medColor, "#50ffffff")
            ctx.lineWidth = 8
            ctx.arc(w * 0.5, h * 1.04, w * 0.24, Math.PI, 0, false)
            ctx.stroke()
        }
    }

    Rectangle {
        x: 287
        y: 102
        width: 86
        height: 14
        radius: 7
        color: Qt.tint(Style.background, "#2effffff")
        border.width: 1
        border.color: Qt.tint(Style.medColor, "#66ffffff")
    }

    Rectangle {
        x: 308
        y: 124
        width: 44
        height: 44
        radius: 22
        color: _root.hasTarget("guide")
            ? _root.targetColor("guide")
            : Qt.tint(Style.backgroundShade, "#36ffffff")
        border.width: 2
        border.color: _root.hasTarget("guide")
            ? _root.targetBorder("guide")
            : Qt.tint(Style.medColor, "#74ffffff")
        visible: _root.hasTarget("guide")
    }

    Label {
        x: 308
        y: 124
        width: 44
        height: 44
        text: "X"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pixelSize: 16
        visible: _root.hasTarget("guide")
    }

    MouseArea {
        x: 308
        y: 124
        width: 44
        height: 44
        enabled: _root.hasTarget("guide") && !hatOnly
        onClicked: _root.targetSelected("guide")
    }

    Rectangle {
        x: 248
        y: 138
        width: 42
        height: 18
        radius: 9
        color: _root.hasTarget("back")
            ? _root.targetColor("back")
            : Qt.tint(Style.background, "#26ffffff")
        border.width: 2
        border.color: _root.hasTarget("back")
            ? _root.targetBorder("back")
            : Qt.tint(Style.medColor, "#66ffffff")
        visible: _root.hasTarget("back")
    }

    Label {
        x: 248
        y: 138
        width: 42
        height: 18
        text: "Back"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 9
        visible: _root.hasTarget("back")
    }

    MouseArea {
        x: 248
        y: 138
        width: 42
        height: 18
        enabled: _root.hasTarget("back") && !hatOnly
        onClicked: _root.targetSelected("back")
    }

    Rectangle {
        x: 370
        y: 138
        width: 42
        height: 18
        radius: 9
        color: _root.hasTarget("start")
            ? _root.targetColor("start")
            : Qt.tint(Style.background, "#26ffffff")
        border.width: 2
        border.color: _root.hasTarget("start")
            ? _root.targetBorder("start")
            : Qt.tint(Style.medColor, "#66ffffff")
        visible: _root.hasTarget("start")
    }

    Label {
        x: 370
        y: 138
        width: 42
        height: 18
        text: "Start"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 9
        visible: _root.hasTarget("start")
    }

    MouseArea {
        x: 370
        y: 138
        width: 42
        height: 18
        enabled: _root.hasTarget("start") && !hatOnly
        onClicked: _root.targetSelected("start")
    }

    Item {
        x: 120
        y: 204
        width: 94
        height: 94
        visible: _root.hasTarget("dpad") || _root.hasTarget("dpad-up")

        Rectangle {
            anchors.centerIn: parent
            width: 28
            height: 88
            radius: 10
            color: _root.currentValue === "dpad"
                ? _root.targetColor("dpad")
                : Qt.tint(Style.backgroundShade, "#4cffffff")
            border.width: 1
            border.color: _root.currentValue === "dpad"
                ? _root.targetBorder("dpad")
                : Qt.tint(Style.medColor, "#70ffffff")
        }

        Rectangle {
            anchors.centerIn: parent
            width: 88
            height: 28
            radius: 10
            color: _root.currentValue === "dpad"
                ? _root.targetColor("dpad")
                : Qt.tint(Style.backgroundShade, "#4cffffff")
            border.width: 1
            border.color: _root.currentValue === "dpad"
                ? _root.targetBorder("dpad")
                : Qt.tint(Style.medColor, "#70ffffff")
        }

        Rectangle {
            anchors.centerIn: parent
            width: 24
            height: 24
            radius: 6
            color: Qt.tint(Style.background, "#36ffffff")
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

    Item {
        x: 152
        y: 134
        width: 112
        height: 112
        visible: _root.hasTarget("left-thumb-x") || _root.hasTarget("left-thumb-y") || _root.hasTarget("left-thumb")

        Rectangle {
            anchors.fill: parent
            radius: 56
            color: _root.currentValue === "left-thumb"
                ? _root.targetColor("left-thumb")
                : Qt.tint(Style.backgroundShade, "#26ffffff")
            border.width: 2
            border.color: _root.currentValue === "left-thumb"
                ? _root.targetBorder("left-thumb")
                : Qt.tint(Style.medColor, "#78ffffff")
        }

        Rectangle {
            anchors.centerIn: parent
            width: 42
            height: 42
            radius: 21
            color: (_root.currentValue === "left-thumb-x" || _root.currentValue === "left-thumb-y")
                ? Style.accent
                : Qt.tint(Style.background, "#46ffffff")
            border.width: 2
            border.color: (_root.currentValue === "left-thumb-x" || _root.currentValue === "left-thumb-y")
                ? Qt.lighter(Style.accent, 1.2)
                : Qt.tint(Style.medColor, "#70ffffff")
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
        x: 349
        y: 196
        width: 100
        height: 100
        visible: _root.hasTarget("right-thumb-x") || _root.hasTarget("right-thumb-y") || _root.hasTarget("right-thumb")

        Rectangle {
            anchors.fill: parent
            radius: 50
            color: _root.currentValue === "right-thumb"
                ? _root.targetColor("right-thumb")
                : Qt.tint(Style.backgroundShade, "#26ffffff")
            border.width: 2
            border.color: _root.currentValue === "right-thumb"
                ? _root.targetBorder("right-thumb")
                : Qt.tint(Style.medColor, "#78ffffff")
        }

        Rectangle {
            anchors.centerIn: parent
            width: 38
            height: 38
            radius: 19
            color: (_root.currentValue === "right-thumb-x" || _root.currentValue === "right-thumb-y")
                ? Style.accent
                : Qt.tint(Style.background, "#46ffffff")
            border.width: 2
            border.color: (_root.currentValue === "right-thumb-x" || _root.currentValue === "right-thumb-y")
                ? Qt.lighter(Style.accent, 1.2)
                : Qt.tint(Style.medColor, "#70ffffff")
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

    Repeater {
        model: [
            { value: "y", text: "Y", x: 483, y: 147, fill: "#D7C830" },
            { value: "x", text: "X", x: 450, y: 178, fill: "#2D7FD3" },
            { value: "b", text: "B", x: 516, y: 178, fill: "#C56D26" },
            { value: "a", text: "A", x: 483, y: 210, fill: "#4C9A43" }
        ]

        delegate: Item {
            x: modelData.x
            y: modelData.y
            width: 34
            height: 34
            visible: _root.hasTarget(modelData.value)

            Rectangle {
                anchors.fill: parent
                radius: 17
                color: _root.faceButtonFill(modelData.value, modelData.fill)
                border.width: 2
                border.color: _root.targetBorder(modelData.value)
            }

            Label {
                anchors.centerIn: parent
                text: modelData.text
                font.bold: true
                color: "white"
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
            { value: "left-thumb-x", text: "LX", x: 162, y: 258 },
            { value: "left-thumb-y", text: "LY", x: 224, y: 258 },
            { value: "right-thumb-x", text: "RX", x: 346, y: 286 },
            { value: "right-thumb-y", text: "RY", x: 406, y: 286 }
        ]

        delegate: Item {
            x: modelData.x
            y: modelData.y
            width: 34
            height: 18
            visible: _root.hasTarget(modelData.value)

            Rectangle {
                anchors.fill: parent
                radius: 9
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
        id: _hint
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
