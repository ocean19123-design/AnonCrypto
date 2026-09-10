import QtQuick
import QtQuick.Layouts

ButtonContainer {
    id: root
    separatorColor: constants.anonBorder
    background: Rectangle {
        color: constants.anonCardBackground
        border.width: 1
        border.color: constants.anonBorder
    }
    headerComponent: Component {
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.leftMargin: constants.paddingSmall
            Layout.rightMargin: constants.paddingSmall
            color: root.separatorColor
        }
    }
}