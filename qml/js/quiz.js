// SPDX-License-Identifier: AGPL-3.0-or-later
// Quiz fetching, parsing, storage and stats — port of the popquizza.com
// Gleam model/update logic (questions format and stats semantics match).

.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var BASE_URL = "https://popquizza.com/priv/static/questions/"
var LAUNCH = new Date(2025, 3, 23) // 2025-04-23, month is 0-based

function dateKey(d) {
    var m = ("0" + (d.getMonth() + 1)).slice(-2)
    var day = ("0" + d.getDate()).slice(-2)
    return "" + d.getFullYear() + m + day
}

function keyToDate(key) {
    return new Date(parseInt(key.slice(0, 4), 10),
                    parseInt(key.slice(4, 6), 10) - 1,
                    parseInt(key.slice(6, 8), 10))
}

function dayNumber(d) {
    var a = new Date(d.getFullYear(), d.getMonth(), d.getDate())
    return Math.round((a - LAUNCH) / 86400000) + 1
}

function displayDate(d) {
    var m = ("0" + (d.getMonth() + 1)).slice(-2)
    var day = ("0" + d.getDate()).slice(-2)
    return day + "-" + m + "-" + ("" + d.getFullYear()).slice(-2)
}

function fetchQuestions(key, cb) {
    var xhr = new XMLHttpRequest()
    var done = false
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE || done)
            return
        done = true
        if (xhr.status === 200) {
            var quiz = parseQuiz(xhr.responseText)
            cb(quiz)
        } else {
            cb(null)
        }
    }
    xhr.open("GET", BASE_URL + key + ".txt")
    xhr.timeout = 15000
    xhr.ontimeout = function () {
        if (!done) {
            done = true
            cb(null)
        }
    }
    xhr.send()
}

// Format: first block is the title; each following block is
// question text, 1-based index of the correct answer, then the answers.
function parseQuiz(text) {
    var blocks = text.replace(/\r\n/g, "\n").trim().split("\n\n")
    if (blocks.length < 2)
        return null
    var title = blocks[0].trim()
    var questions = []
    for (var i = 1; i < blocks.length; i++) {
        var lines = blocks[i].split("\n").map(function (l) { return l.trim() })
        if (lines.length < 3)
            return null
        var correct = parseInt(lines[1], 10)
        if (isNaN(correct))
            return null
        var answers = []
        for (var j = 2; j < lines.length; j++)
            answers.push({ apos: j - 1, atext: lines[j] })
        questions.push({ qid: i, qtext: lines[0], correct: correct,
                         selected: 0, answers: answers })
    }
    return { title: title, questions: questions }
}

function resultsTitle(score) {
    var titles = ["Bottom of the pops!", "Tomorrow's another day!",
                  "Must Try Harder!", "Keep on keeping on!", "Bubbling under!",
                  "Highest new entry!", "Rising star!", "Climbing the chart!",
                  "Flying high!", "Almost there!", "No 1 Smash Hit!"]
    return titles[score] !== undefined ? titles[score] : "Well done!"
}

function shareString(results) {
    return results.map(function (r) { return r ? "✅" : "❌" }).join("")
}

// --- storage ---

function db() {
    return LS.LocalStorage.openDatabaseSync("harbour-popquizza", "1.0",
                                            "Popquizza results", 100000)
}

function initDb() {
    db().transaction(function (tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS results(" +
                      "date TEXT PRIMARY KEY, score INT, out_of INT, " +
                      "answers TEXT, results TEXT)")
    })
}

function getResult(key) {
    var found = null
    db().readTransaction(function (tx) {
        var rs = tx.executeSql("SELECT * FROM results WHERE date = ?", [key])
        if (rs.rows.length > 0) {
            var row = rs.rows.item(0)
            found = { score: row.score, outOf: row.out_of,
                      answers: JSON.parse(row.answers),
                      results: JSON.parse(row.results) }
        }
    })
    return found
}

function saveResult(key, score, outOf, answers, results) {
    db().transaction(function (tx) {
        tx.executeSql("INSERT OR REPLACE INTO results VALUES(?,?,?,?,?)",
                      [key, score, outOf,
                       JSON.stringify(answers), JSON.stringify(results)])
    })
}

// Newest first, like the web app's history view.
function allResults() {
    var out = []
    db().readTransaction(function (tx) {
        var rs = tx.executeSql(
            "SELECT date, score, out_of, results FROM results ORDER BY date DESC")
        for (var i = 0; i < rs.rows.length; i++) {
            var row = rs.rows.item(i)
            out.push({ key: row.date, score: row.score, outOf: row.out_of,
                       results: JSON.parse(row.results) })
        }
    })
    return out
}

// Streak counts consecutive played days ending today; count/total cover
// everything ever played (matches the web app's calc_* functions).
function stats(todayKey) {
    var played = {}
    var count = 0
    var total = 0
    db().readTransaction(function (tx) {
        var rs = tx.executeSql("SELECT date, score FROM results")
        for (var i = 0; i < rs.rows.length; i++) {
            var row = rs.rows.item(i)
            played[row.date] = true
            count++
            total += row.score
        }
    })
    var streak = 0
    var d = keyToDate(todayKey)
    while (played[dateKey(d)]) {
        streak++
        d.setDate(d.getDate() - 1)
    }
    return { count: count, streak: streak, total: total }
}
