// SPDX-License-Identifier: AGPL-3.0-or-later
import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string title
    property string value

    width: parent.width / 4
    height: valueLabel.height + titleLabel.height + Theme.paddingMedium

    Label {
        id: valueLabel
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraLarge
        color: Theme.highlightColor
        text: value
    }

    Label {
        id: titleLabel
        anchors {
            top: valueLabel.bottom
            horizontalCenter: parent.horizontalCenter
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: title
    }
}
