// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import "../js/quiz.js" as Quiz

Page {
    id: page

    // status/linkTitle (not data/name) so native targets get inline text
    // rather than a file attachment; the Android bridge maps status →
    // EXTRA_TEXT and linkTitle → EXTRA_SUBJECT.
    ShareAction {
        id: shareAction
        title: "Share your results"
        mimeType: "text/x-url"
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: Quiz.resultsTitle(app.score)
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                text: "You scored " + app.score + " out of "
                      + app.questions.count
            }

            Label {
                x: Theme.horizontalPageMargin
                text: Quiz.shareString(app.resultsList)
            }

            Separator {
                width: parent.width
                color: Theme.primaryColor
                horizontalAlignment: Qt.AlignHCenter
            }

            Row {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                StatItem { title: "Count"; value: "" + app.statsData.count }
                StatItem { title: "Streak"; value: "" + app.statsData.streak }
                StatItem {
                    title: "Average"
                    value: app.statsData.count > 0
                           ? (app.statsData.total / app.statsData.count).toFixed(2)
                           : "-"
                }
                StatItem {
                    title: "Total"
                    value: "" + app.statsData.total
                    onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"))
                }
            }

            Separator {
                width: parent.width
                color: Theme.primaryColor
                horizontalAlignment: Qt.AlignHCenter
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: "A new set of questions will appear at midnight"
            }

            Item { width: 1; height: Theme.paddingLarge }

            ButtonLayout {
                Button {
                    text: "Share results"
                    onClicked: {
                        shareAction.resources =
                                [{ "type": "text/x-url",
                                   "linkTitle": "Popquizza results",
                                   "status": app.shareText() }]
                        shareAction.trigger()
                    }
                }
                Button {
                    text: "See answers"
                    onClicked: pageStack.pop()
                }
            }
        }

        VerticalScrollDecorator { }
    }
}
