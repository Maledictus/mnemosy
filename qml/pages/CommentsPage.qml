/*
The MIT License (MIT)

Copyright (c) 2016-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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
import harbour.mnemosy 1.0

import "../components"
import "../utils/Utils.js" as Utils

Page {
    id: commentsPage

    property int dItemId
    property string journal

    function attachPage() {
        if (pageStack._currentContainer.attachedContainer === null &&
                mnemosyManager.logged) {
            pageStack.pushAttached(Qt.resolvedUrl("ProfilePage.qml"))
        }
    }

    function load() {
        mnemosyManager.abortRequest()
        mnemosyManager.commentsModel.clear()
        mnemosyManager.getComments(dItemId, journal)
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            attachPage()
        }
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: mnemosyManager.busy
        visible: running
    }

    SilicaListView {
        id: commentsView

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Comments")
        }

        ViewPlaceholder {
            enabled: !mnemosyManager.busy && commentsView.count === 0
            text: qsTr("There are no comments. Pull down to refresh.")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    mnemosyManager.abortRequest()
                    mnemosyManager.commentsModel.clear()
                    mnemosyManager.getComments(dItemId, journal)
                }
            }

            MenuItem {
                text: qsTr("Add comment")
                onClicked: {
                    var dialog = pageStack.push("../dialogs/AddCommentDialog.qml")
                    dialog.accepted.connect(function () {
                        mnemosyManager.addComment(journal,
                                0, dItemId,
                                dialog.subject, dialog.body)
                    })
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Load More...")
                visible: mnemosyManager.commentsModel.lastLoadedPage <
                        mnemosyManager.commentsModel.pagesCount
                onClicked: {
                    mnemosyManager.getComments(dItemId, journal,
                            mnemosyManager.commentsModel.lastLoadedPage + 1)
                }
            }

            MenuItem {
                text: qsTr("Go to top")
                onClicked: {
                    commentsView.scrollToTop()
                }
            }

            visible: !mnemosyManager.busy &&
                    commentsView.count > 0
        }

        model: mnemosyManager.commentsModel

        spacing: Theme.paddingSmall

        delegate: ListItem {
            id: rootDelegateItem

            width: commentsView.width
            contentHeight: contentItem.childrenRect.height +
                    2 * Theme.paddingSmall

            clip: true

            menu: ContextMenu {
                MenuItem {
                    visible: commentPrivileges & Mnemosy.Edit
                    text: qsTr("Edit")
                    onClicked: {
                        var dialog = pageStack.push("../dialogs/AddCommentDialog.qml",
                                { type: "edit", subject: commentSubject,
                                    body: commentBody })
                        dialog.accepted.connect(function() {
                            if (dialog.subject.length === 0 &&
                                        dialog.body.length === 0) {
                                removeComment()
                            }
                            else {
                                mnemosyManager.editComment (journal, commentDTalkId,
                                       dialog.subject, dialog.body)
                            }
                        })
                    }
                }

                MenuItem {
                    visible: commentPrivileges & Mnemosy.Delete
                    text: qsTr("Delete")
                    onClicked: {
                        var dialog = pageStack.push("../dialogs/DeleteCommentDialog.qml",
                                { posterName: commentPosterName })
                        dialog.accepted.connect(function() {
                            mnemosyManager.deleteComment(journal, commentDTalkId, dialog.deleteMask,
                                    commentPosterName)
                        })
                    }
                }
            }

            property string _style: "<style>" +
                    "a:link { color:" + Theme.highlightColor + "; }" +
                    "p { color:" + Theme.primaryColor + "; }" +
                    "</style>"

            Column {
                spacing: Theme.paddingSmall

                anchors.top: parent.top
                anchors.topMargin: Theme.paddingSmall
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin +
                        Theme.paddingMedium * (commentLevel % 4)
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                EntryHeaderItem {
                    width: parent.width

                    posterAvatar: commentPosterPicUrl
                    posterName: commentPosterName.toUpperCase()
                    postDate: Utils.generateDateString(commentDatePost, "dd MMM yyyy hh:mm")

                    onClicked: {
                        var page = pageStack.push(Qt.resolvedUrl("UserJournalPage.qml"),
                                { journalName: commentPosterName,
                                    modelType: Mnemosy.UserModel,
                                    userPicUrl: commentPosterPicUrl })
                        page.load()
                    }
                }

                Label {
                    id: subjectLabel

                    visible: commentSubject !== ""

                    width: parent.width

                    wrapMode: Text.WordWrap

                    font.pixelSize: Theme.fontSizeMedium
                    font.family: Theme.fontFamilyHeading
                    font.bold: true

                    style: Text.RichText

                    text: commentSubject
                }

                Label {
                    id: commentLabel

                    width: parent.width

                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    horizontalAlignment: Qt.AlignJustify

                    font.pixelSize: Theme.fontSizeSmall
                    text: _style + (commentHasArgs ?
                            commentBody.arg(width) :
                            commentBody)

                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                }

                ClickableLabel {
                    id: openThreadClickableLabel

                    visible: commentChildrenCount > 0

                    label.text: qsTr("Expand thread")
                    label.horizontalAlignment: Qt.AlignRight

                    onClicked: {
                        var thread = mnemosyManager.commentsModel.getThread(commentDTalkId)
                        if (thread.length === 0) {
                            return
                        }

                        var page = pageStack.push(Qt.resolvedUrl("CommentsThreadPage.qml"),
                                { dItemId: dItemId, journal: journal, comments: thread })
                        page.load()
                    }
                }
            }

            onClicked: {
                if (commentPrivileges & Mnemosy.Reply) {
                    var dialog = pageStack.push("../dialogs/AddCommentDialog.qml",
                            { parentSubject: commentSubject,
                                parentBody: commentBody,
                                parentAuthorPicUrl: commentPosterPicUrl,
                                parentAuthor: commentPosterName })
                    dialog.accepted.connect(function() {
                        mnemosyManager.addComment (journal, commentDTalkId,
                                dItemId, dialog.subject, dialog.body)
                    })
                }
                else {
                    mnemosyManager.showError(qsTr("You can not add reply to this comment"),
                            Mnemosy.LiveJournalError)
                }
            }
        }
    }
}
