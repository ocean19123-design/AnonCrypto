import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Heading {
    id: root

    Layout.topMargin: constants.paddingXLarge
    Layout.bottomMargin: constants.paddingMedium

    font.pixelSize: constants.fontSizeMedium
    font.bold: true
    color: constants.anonAccent
}