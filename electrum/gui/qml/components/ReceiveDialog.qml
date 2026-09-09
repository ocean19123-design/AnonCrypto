import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQml.Models

import org.electrum 1.0

import "controls"

ElDialog {
    id: dialog

    title: qsTr('Receive Payment')
    iconSource: Qt.resolvedUrl('../../icons/tab_receive.png')

    property string key
    property bool isLightning: request.isLightning

    property string _bolt11: request.bolt11
    property string _bip21uri: request.bip21
    property string _address: request.address
    property bool _render_qr: false // delay qr rendering until dialog is shown

    signal requestPaid

    padding: 0

    function getPaidTxid() {
        return request.paidTxid
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true

            leftMargin: constants.paddingLarge
            rightMargin: constants.paddingLarge

            contentHeight: rootLayout.height
            clip: true
            interactive: height < contentHeight

            ColumnLayout {
                id: rootLayout
                width: parent.width
                spacing: constants.paddingMedium

                DialogHighlightPane {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width
                        Rectangle {
                            id: qrbg
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: constants.paddingMedium
                            Layout.bottomMargin: constants.paddingMedium

                            Layout.preferredWidth: dialog.width * 3/4
                            Layout.preferredHeight: dialog.width * 3/4

                            radius: constants.paddingLarge
                            color: 'white'

                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 10
                                samples: 20
                                color: Qt.rgba(0.09, 0.53, 1, 0.2)
                                verticalOffset: 2
                            }

                            QRImage {
                                anchors.centerIn: parent
                                anchors.margins: constants.paddingLarge
                                qrdata: _bolt11
                                    ? _bolt11
                                    : _bip21uri
                                        ? _bip21uri
                                        : _address
                                render: _render_qr
                                enableToggleText: true
                            }
                        }
                    }
                }

                Rectangle {
                    height: 1
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: qrbg.width
                    color: constants.anonBorder
                }

                GridLayout {
                    columns: 2
                    Layout.maximumWidth: qrbg.width
                    Layout.alignment: Qt.AlignHCenter

                    Label {
                        text: qsTr('Status')
                        color: constants.anonTextSecondary
                        font.bold: true
                    }
                    Label {
                        text: request.status_str
                        color: constants.anonTextPrimary
                    }
                    Label {
                        text: qsTr('Message')
                        color: constants.anonTextSecondary
                        font.bold: true
                    }
                    Label {
                        visible: request.message
                        Layout.fillWidth: true
                        text: request.message
                        wrapMode: Text.Wrap
                        color: constants.anonTextPrimary
                    }
                    Label {
                        visible: !request.message
                        Layout.fillWidth: true
                        text: qsTr('unspecified')
                        color: constants.anonTextSecondary
                    }
                    Label {
                        text: qsTr('Amount')
                        color: constants.anonTextSecondary
                        font.bold: true
                    }
                    FormattedAmount {
                        visible: !request.amount.isEmpty
                        valid: !request.amount.isEmpty
                        amount: request.amount
                    }
                    Label {
                        visible: request.amount.isEmpty
                        text: qsTr('unspecified')
                        color: constants.anonTextSecondary
                    }
                }

                Rectangle {
                    height: 1
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: qrbg.width
                    color: constants.anonBorder
                }

            }

        }

        DialogButtonContainer {
            id: buttons
            Layout.fillWidth: true

            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: constants.paddingXXLarge * 2

                icon.source: '../../icons/copy_bw.png'
                icon.color: constants.anonAccent
                text: 'Copy'
                onClicked: {
                    AppController.textToClipboard(_bolt11
                        ? _bolt11.toLowerCase()
                        : _bip21uri
                            ? _bip21uri
                            : _address
                    )
                    toaster.show(this, qsTr('Copied!'))
                }
            }
            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: constants.paddingXXLarge * 2

                icon.source: '../../icons/share.png'
                icon.color: constants.anonAccent
                text: 'Share'
                onClicked: {
                    enabled = false
                    AppController.doShare(
                        _bolt11
                            ? _bolt11.toLowerCase()
                            : _bip21uri
                                ? _bip21uri
                                : _address,
                        _bolt11 || _bip21uri
                            ? qsTr('Payment Request')
                            : qsTr('Onchain address')
                    )
                    enabled = true
                }
            }
        }
    }

    RequestDetails {
        id: request
        wallet: Daemon.currentWallet
        onStatusChanged: {
            if (status == RequestDetails.Paid || status == RequestDetails.Unconfirmed) {
                requestPaid()
            }
        }
    }

    Toaster {
        id: toaster
    }

    Component.onCompleted: {
        request.key = dialog.key
    }

    // hack. delay qr rendering until dialog is shown
    Connections {
        target: dialog.enter
        function onRunningChanged() {
            if (!dialog.enter.running) {
                dialog._render_qr = true
            }
        }
    }
}