// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/quiz.js" as Quiz

CoverBackground {
    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingMedium
        width: parent.width - 2 * Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeMedium
            font.bold: true
            color: Theme.highlightColor
            text: "POPQUIZZA"
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            visible: app.quizState === "submitted"
            text: app.score + "/" + app.questions.count
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            text: app.quizState === "submitted"
                  ? "Streak: " + app.statsData.streak
                  : "Day " + Quiz.dayNumber(app.quizDate)
        }
    }
}
