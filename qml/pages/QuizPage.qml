// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.6
import Sailfish.Silica 1.0
import "../js/quiz.js" as Quiz

Dialog {
    id: page

    // Forward swipe submits (Silica accept gesture); blocked until every
    // question is answered. After submission it re-opens the results.
    canAccept: app.canSubmit || app.quizState === "submitted"
    acceptDestination: Qt.resolvedUrl("ResultsPage.qml")
    onAccepted: {
        if (app.quizState === "loaded")
            app.submit()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: "Your history"
                onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"))
            }
            MenuItem {
                text: "Reload"
                visible: app.quizState === "error"
                onClicked: app.load()
            }
            MenuItem {
                text: "Show results"
                visible: app.quizState === "submitted"
                onClicked: pageStack.push(Qt.resolvedUrl("ResultsPage.qml"))
            }
        }

        Column {
            id: column
            width: page.width

            DialogHeader {
                title: "POPQUIZZA"
                acceptText: app.quizState === "submitted" ? "Results" : "Submit"
                cancelText: ""
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                text: app.quizState === "loading" ? "Loading…"
                    : app.quizTitle === "" ? ""
                    : app.quizTitle + " — Day "
                      + Quiz.dayNumber(app.quizDate) + ": "
                      + Quiz.displayDate(app.quizDate)
            }

            Item { width: 1; height: Theme.paddingLarge }

            Label {
                visible: app.quizState === "error"
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                text: "No quiz found for today. Check back later!"
            }

            Repeater {
                model: questionsModel

                delegate: Column {
                    id: questionItem
                    property int qIndex: index
                    property int qSelected: selected
                    property int qCorrect: correct
                    width: column.width
                    spacing: Theme.paddingSmall
                    bottomPadding: Theme.paddingLarge

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * x
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                        color: Theme.highlightColor
                        text: qtext
                    }

                    Repeater {
                        model: answers

                        delegate: BackgroundItem {
                            id: answerItem
                            width: column.width
                            height: answerLabel.height + 2 * Theme.paddingMedium

                            property bool isSelected: questionItem.qSelected === apos
                            property bool isCorrect: questionItem.qCorrect === apos
                            property bool showMarks: app.quizState === "submitted"

                            Rectangle {
                                anchors.fill: parent
                                color: !showMarks && isSelected
                                           ? Theme.rgba(Theme.highlightBackgroundColor,
                                                        Theme.highlightBackgroundOpacity)
                                       : showMarks && isSelected && isCorrect ? "#404caf50"
                                       : showMarks && isSelected && !isCorrect ? "#40f44336"
                                       : Theme.rgba(Theme.primaryColor, 0.05)
                            }

                            Label {
                                id: answerLabel
                                anchors {
                                    left: parent.left
                                    leftMargin: Theme.horizontalPageMargin
                                    right: mark.left
                                    rightMargin: Theme.paddingMedium
                                    verticalCenter: parent.verticalCenter
                                }
                                wrapMode: Text.Wrap
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: showMarks && isSelected
                                text: atext
                            }

                            Label {
                                id: mark
                                anchors {
                                    right: parent.right
                                    rightMargin: Theme.horizontalPageMargin
                                    verticalCenter: parent.verticalCenter
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                text: !showMarks ? ""
                                      : isCorrect ? "✔"
                                      : isSelected ? "✘"
                                      : ""
                                color: isCorrect ? "#4caf50" : "#f44336"
                            }

                            onClicked: app.selectAnswer(questionItem.qIndex, apos)
                        }
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: app.quizState === "loaded"
                          || app.quizState === "submitted"
                enabled: page.canAccept
                text: app.quizState === "submitted" ? "Show results"
                    : app.canSubmit ? "Submit"
                    : "Submit (" + app.answeredCount + "/"
                      + questionsModel.count + ")"
                onClicked: page.accept()
            }
        }

        VerticalScrollDecorator { }
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: app.quizState === "loading"
    }
}
