// -*- coding: utf-8; -*-
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Window

import Gremlin.ActionPlugins
import "../../qml"

Item {
    property PlaySoundModel action

    implicitHeight: _content.height

    RowLayout {
        id: _content

        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            Layout.preferredWidth: 110

            text: qsTr("Audio filename")
        }

        JGTextField {
            id: _soundFilename

            Layout.fillWidth: true

            text: action.soundFilename
            placeholderText: null !== action ? null : qsTr("Input the name of the audio file to play.")

            selectByMouse: true

            onTextChanged: () => { action.soundFilename = text }
        }

        Button {
            text: qsTr("Select File")

            onClicked: () => { _fileDialog.open() }
        }

        Label {
            Layout.preferredWidth: 50

            text: qsTr("Volume")
        }

        JGSpinBox {
            Layout.preferredWidth: 100

            value: action.soundVolume
            from: 0
            to: 100

            onValueModified: () => { action.soundVolume = value }
        }
   }

   FileDialog {
        id: _fileDialog

        nameFilters: [qsTr("Audio files (*.wav *.mp3 *.ogg)")]
        title: qsTr("Select a File")

        onAccepted: () => {
            _soundFilename.text = selectedFile.toString().substring("file:///".length)
        }
    }
}
