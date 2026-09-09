import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Controls.Material.impl

TabButton {
    id: control
    checkable: false

    property bool textUnderIcon: true
    property bool pressAndHoldIndicator: false

    font.pixelSize: constants.fontSizeSmall
    font.bold: true
    icon.width: constants.iconSizeMedium
    icon.height: constants.iconSizeMedium
    display: textUnderIcon ? IconLabel.TextUnderIcon : IconLabel.TextBesideIcon

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled 
            ? constants.anonDisabled 
            : control.down || control.checked 
                ? constants.anonAccent 
                : constants.anonTextPrimary
    }

    background: Rectangle {
        color: control.down 
            ? constants.anonHoverBackground 
            : "transparent"
        radius: constants.paddingSmall
    }

    Rectangle {
        id: indicator
        anchors.top: control.top
        anchors.horizontalCenter: control.horizontalCenter
        width: 0
        opacity: 0
        height: 2
        radius: 1
        color: constants.anonAccent

        states: State {
            name: 'pressing'
            when: pressAndHoldIndicator && control.pressed
            PropertyChanges {
                target: indicator
                width: control.width
                opacity: 1
            }
        }

        transitions: Transition {
            to: 'pressing'
            SequentialAnimation {
                PauseAnimation {
                    duration: 200
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: indicator
                        property: "width"
                        duration: 600
                    }
                    NumberAnimation {
                        target: indicator
                        property: "opacity"
                        duration: 600
                    }
                }
            }
        }
    }
}