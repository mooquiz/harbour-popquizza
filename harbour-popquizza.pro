TARGET = harbour-popquizza

CONFIG += sailfishapp

SOURCES += src/harbour-popquizza.cpp

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

DISTFILES += \
    qml/harbour-popquizza.qml \
    qml/cover/CoverPage.qml \
    qml/pages/QuizPage.qml \
    qml/pages/ResultsPage.qml \
    qml/pages/HistoryPage.qml \
    qml/js/quiz.js \
    rpm/harbour-popquizza.spec \
    harbour-popquizza.desktop
