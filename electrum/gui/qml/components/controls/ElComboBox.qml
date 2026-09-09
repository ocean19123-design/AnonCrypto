import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

ComboBox {
    id: cb

    property int implicitChildrenWidth: 64

    // make combobox implicit width a multiple of 32, so it aligns with others
    implicitWidth: Math.ceil(implicitChildrenWidth/32)*32 + 2 * constants.paddingXLarge

    // redefine contentItem, as the default crops the text easily
    contentItem: Label {
        id: contentLabel
        text: cb.currentText
        padding: constants.paddingLarge
        rightPadding: constants.paddingXXLarge
        font.pixelSize: constants.fontSizeMedium
        color: constants.anonTextPrimary
    }

    background: Rectangle {
        color: constants.anonInputBackground
        border.width: 1
        border.color: constants.anonBorder
        radius: constants.paddingSmall
    }

    popup: Popup {
        y: cb.height + 2
        width: cb.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: cb.popup.visible ? cb.delegateModel : null
            currentIndex: cb.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: constants.anonCardBackground
            border.width: 1
            border.color: constants.anonBorder
            radius: constants.paddingSmall
        }
    }

    delegate: ItemDelegate {
        width: cb.width
        contentItem: Text {
            text: cb.textRole ? (Array.isArray(cb.model) ? modelData[cb.textRole] : model[cb.textRole]) : modelData
            color: highlighted ? constants.anonAccent : constants.anonTextPrimary
            font: cb.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: cb.highlightedIndex === index
        background: Rectangle {
            color: highlighted ? constants.anonHoverBackground : "transparent"
            radius: constants.paddingXSmall
        }
    }

    indicator: Item {
        x: cb.width - width - cb.rightPadding
        y: cb.topPadding + (cb.availableHeight - height) / 2
        width: 12
        height: 12

        Label {
            anchors.centerIn: parent
            text: "▼"
            font.pixelSize: constants.fontSizeXSmall
            color: constants.anonTextSecondary
        }
    }

    // determine widest element and store in implicitChildrenWidth
    function updateImplicitWidth() {
        for (let i = 0; i < cb.count; i++) {
            var txt = cb.textAt(i)
            var txtwidth = fontMetrics.advanceWidth(txt)
            if (txtwidth > cb.implicitChildrenWidth) {
                cb.implicitChildrenWidth = txtwidth
            }
        }
    }

    FontMetrics {
        id: fontMetrics
        font: contentLabel.font
    }

    Component.onCompleted: updateImplicitWidth()
    onModelChanged: updateImplicitWidth()
}