// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/quiz.js" as Quiz
import "pages"
import "cover"

ApplicationWindow {
    id: app

    // "loading" | "error" | "loaded" | "submitted"
    property string quizState: "loading"
    property string quizTitle: ""
    property string loadedKey: ""
    property date quizDate: new Date()
    property int answeredCount: 0
    property int score: 0
    property var resultsList: []
    property var statsData: ({ count: 0, streak: 0, total: 0 })

    property bool canSubmit: quizState === "loaded" && questionsModel.count > 0
                             && answeredCount === questionsModel.count

    ListModel { id: questionsModel }
    property alias questions: questionsModel

    function load() {
        quizState = "loading"
        quizTitle = ""
        answeredCount = 0
        score = 0
        resultsList = []
        questionsModel.clear()
        quizDate = new Date()
        loadedKey = Quiz.dateKey(quizDate)
        var key = loadedKey
        Quiz.fetchQuestions(key, function (quiz) {
            if (key !== loadedKey)
                return
            if (!quiz) {
                quizState = "error"
                return
            }
            quizTitle = quiz.title
            for (var i = 0; i < quiz.questions.length; i++)
                questionsModel.append(quiz.questions[i])
            quizState = "loaded"
            restoreToday(key)
        })
    }

    function restoreToday(key) {
        var saved = Quiz.getResult(key)
        if (!saved || saved.outOf !== questionsModel.count)
            return
        for (var i = 0; i < questionsModel.count; i++)
            questionsModel.setProperty(i, "selected", saved.answers[i])
        answeredCount = questionsModel.count
        score = saved.score
        resultsList = saved.results
        statsData = Quiz.stats(key)
        quizState = "submitted"
        pageStack.push(Qt.resolvedUrl("pages/ResultsPage.qml"),
                       undefined, PageStackAction.Immediate)
    }

    function selectAnswer(qIndex, pos) {
        if (quizState !== "loaded")
            return
        if (questionsModel.get(qIndex).selected === 0)
            answeredCount++
        questionsModel.setProperty(qIndex, "selected", pos)
    }

    function submit() {
        if (!canSubmit)
            return
        var answers = []
        var results = []
        var s = 0
        for (var i = 0; i < questionsModel.count; i++) {
            var q = questionsModel.get(i)
            answers.push(q.selected)
            var right = q.selected === q.correct
            results.push(right)
            if (right)
                s++
        }
        score = s
        resultsList = results
        Quiz.saveResult(loadedKey, s, questionsModel.count, answers, results)
        statsData = Quiz.stats(loadedKey)
        quizState = "submitted"
        // navigation to ResultsPage is the quiz dialog's acceptDestination
    }

    function shareText() {
        return "I scored " + score + "/" + questionsModel.count
                + " on " + quizTitle + "\n"
                + Quiz.shareString(resultsList) + "\n"
                + "popquizza.com #popquizza"
    }

    // New questions appear at midnight — reload when the app comes back
    // to the foreground on a new day.
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active
                    && loadedKey !== Quiz.dateKey(new Date())) {
                pageStack.replaceAbove(null,
                                       Qt.resolvedUrl("pages/QuizPage.qml"),
                                       {}, PageStackAction.Immediate)
                load()
            }
        }
    }

    Component.onCompleted: {
        Quiz.initDb()
        load()
    }

    initialPage: Component { QuizPage { } }
    cover: Component { CoverPage { } }
    allowedOrientations: defaultAllowedOrientations
}
