// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/quiz.js" as Quiz

Page {
    id: page

    SilicaListView {
        anchors.fill: parent
        model: ListModel { id: historyModel }

        header: PageHeader { title: "Your history" }

        ViewPlaceholder {
            enabled: historyModel.count === 0
            text: "No results yet!"
        }

        delegate: ListItem {
            contentHeight: Theme.itemSizeSmall

            Row {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingLarge

                Label {
                    width: Theme.itemSizeSmall
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    text: "Day " + dayNum
                }
                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    text: scoreText
                }
                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    text: marks
                }
            }
        }

        VerticalScrollDecorator { }
    }

    Component.onCompleted: {
        var rows = Quiz.allResults()
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i]
            historyModel.append({
                dayNum: Quiz.dayNumber(Quiz.keyToDate(r.key)),
                scoreText: r.score + "/" + r.outOf,
                marks: Quiz.shareString(r.results)
            })
        }
    }
}
