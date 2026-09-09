import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Pane {
    objectName: 'About'

    property string title: qsTr("About Anon Flash")

    Flickable {
        anchors.fill: parent
        contentHeight: rootLayout.height
        interactive: height < contentHeight

        GridLayout {
            id: rootLayout
            columns: 2
            width: parent.width

            Item {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width * 0.4
                Layout.preferredHeight: parent.width * 0.4

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: width
                    radius: width / 2
                    color: constants.accentColor
                    border.width: 2
                    border.color: Qt.lighter(constants.accentColor, 1.3)

                    Label {
                        anchors.centerIn: parent
                        text: "AF"
                        font.pixelSize: parent.width * 0.35
                        font.bold: true
                        color: "white"
                    }
                }
            }

            Label {
                text: qsTr('Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.electrum_version
            }
            Label {
                text: qsTr('Protocol version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.protocol_version
            }
            Label {
                text: qsTr('Qt Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.qt_version
            }
            Label {
                text: qsTr('PyQt Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.pyqt_version
            }
            Label {
                text: qsTr('License')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: qsTr('MIT License')
            }
            Item {
                width: 1
                height: constants.paddingXLarge
                Layout.columnSpan: 2
            }
            Label {
                text: qsTr('Anon Flash - Fast. Private. Bitcoin.')
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}