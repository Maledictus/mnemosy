/*
The MIT License (MIT)

Copyright (c) 2016 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
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
import org.mnemosy 1.0

import "../components"
import "../utils/Utils.js" as Utils

Page {
    id: entryPage

    property variant event
    property variant modelType: Mnemosy.FeedModel

    onStatusChanged: {
        attachPage()

        if (status == PageStatus.Active) {
            if (event.fullEvent === "") {
                mnemosyManager.getEvent(event.dItemId, event.posterName, modelType)
            }
        }
    }

    function attachPage() {
        if (status == PageStatus.Active &&
                pageStack._currentContainer.attachedContainer === null &&
                mnemosyManager.logged) {
            pageStack.pushAttached(Qt.resolvedUrl("ProfilePage.qml"))
        }
    }

    Connections {
        target: mnemosyManager
        onGotEvent: {
            event = newEvent
        }
    }

    SilicaFlickable {
        id: eventView

        anchors.fill: parent
        anchors.margins: Theme.paddingSmall

        contentWidth: width
        contentHeight: contentItem.childrenRect.height + Theme.paddingSmall

        clip: true

        property string _style: "<style>" +
                "a:link { color:" + Theme.highlightColor + "; }" +
                "p { color:" + Theme.primaryColor + "; }" +
                "</style>"

        Column {
            spacing: Theme.paddingSmall

            width: parent.width

            EntryHeaderItem {
                width: parent.width

                posterAvatar: event.posterPicUrl
                posterName: event.posterName.toUpperCase()
                postDate: Utils.generateDateString(event.postDate)
            }

            Label {
                id: tagsLabel

                width: parent.width

                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true

                wrapMode: Text.WordWrap

                visible: event.tags.length > 0

                text: qsTr("Tags: ") + event.tags
            }

            Label {
                id: subjectLabel

                width: parent.width

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                font.pixelSize: Theme.fontSizeMedium
                font.family: Theme.fontFamilyHeading
                font.bold: true

                style: Text.RichText

                text: event.subject
            }

            Label {
                id: entryText

                width: parent.width

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText

                font.pixelSize: Theme.fontSizeSmall
                text: eventView._style + event.fullEvent.replace("%IMG_WIDTH%",
                        mainWindow.orientation == Orientation.Portrait ?
                                Screen.width - 2 * Theme.paddingSmall :
                                Screen.height - 2 * Theme.paddingSmall)
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: mnemosyManager.busy
        visible: running
    }

}