/*
The MIT License(MIT)

Copyright (c) 2016-2018 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addFriendDialog

    property alias groupName: groupNameField.text
    property alias privateGroup: privateGroupSwitch.checked

    Column {
        id: column

        anchors.fill: parent

        clip: true

        spacing: Theme.paddingMedium

        DialogHeader {
            acceptText: qsTr("Add")
            cancelText: qsTr("Cancel")
        }

        TextField {
            id: groupNameField

            width: parent.width

            placeholderText: qsTr("Group name")

            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: accept()
        }

        TextSwitch {
            id: privateGroupSwitch

            width: parent.width

            checked: true
            text: qsTr("Private group")
        }
    }

    canAccept: groupNameField.text !== ""
}
