import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.electrum 1.0

import "controls"

ElDialog {
    id: dialog

    property var invoice  // type Invoice
    property bool payImmediately: false
    property string broadcastTxid

    signal doPay
    signal invoiceAmountChanged

    title: invoice.invoiceType == Invoice.OnchainInvoice ? qsTr('On-chain Invoice') : qsTr('Lightning Invoice')
    iconSource: Qt.resolvedUrl('../../icons/tab_send.png')

    padding: 0

    property bool _canMax: invoice.invoiceType == Invoice.OnchainInvoice

    property var _invoice_amount: invoice.amount  // type: Amount

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true

            leftMargin: constants.paddingLarge
            rightMargin: constants.paddingLarge

            contentHeight: rootLayout.height
            clip:true
            interactive: height < contentHeight

            GridLayout {
                id: rootLayout
                width: parent.width

                columns: 2

                InfoTextArea {
                    id: helpText
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.bottomMargin: constants.paddingLarge
                    visible: text
                    text:  invoice.userinfo ? invoice.userinfo : invoice.statusString
                    iconStyle: invoice.status == Invoice.Failed || invoice.status == Invoice.Unknown
                        ? InfoTextArea.IconStyle.Warn
                        : invoice.status == Invoice.Expired
                            ? InfoTextArea.IconStyle.Error
                            : invoice.status == Invoice.Inflight || invoice.status == Invoice.Routing || invoice.status == Invoice.Unconfirmed
                                ? InfoTextArea.IconStyle.Progress
                                : invoice.status == Invoice.Paid
                                    ? InfoTextArea.IconStyle.Done
                                    : invoice.status == Invoice.Unpaid && invoice.expiration > 0
                                        ? invoice.canPay
                                            ? InfoTextArea.IconStyle.Pending
                                            : invoice.userinfoStatus == Invoice.Warning
                                                ? InfoTextArea.IconStyle.Warn
                                                : InfoTextArea.IconStyle.Error
                                        : InfoTextArea.IconStyle.Info
                    backgroundColor: constants.anonCardBackground
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingSmall
                    visible: invoice.invoiceType == Invoice.OnchainInvoice
                    text: qsTr('Address')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: invoice.invoiceType == Invoice.OnchainInvoice
                    Layout.preferredHeight: addressLayout.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    RowLayout {
                        id: addressLayout
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingLarge * 2
                        Label {
                            text: invoice.address
                            font.pixelSize: constants.fontSizeMedium
                            font.family: FixedFont
                            color: constants.anonTextPrimary
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        ToolButton {
                            icon.source: '../../icons/share.png'
                            icon.color: constants.anonAccent
                            onClicked: {
                                var dialog = app.genericShareDialog.createObject(app, {
                                    title: qsTr('Address'),
                                    text: invoice.address
                                })
                                dialog.open()
                            }
                        }
                    }
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingSmall
                    text: qsTr('Description')
                    visible: invoice.message
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: invoice.message
                    Layout.preferredHeight: messageLabel.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    Label {
                        id: messageLabel
                        anchors.centerIn: parent
                        text: invoice.message
                        width: parent.width - constants.paddingLarge * 2
                        font.pixelSize: constants.fontSizeLarge
                        color: constants.anonTextPrimary
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                    }
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    text: qsTr('Amount to send')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    id: amountContainer

                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: amountLayout.height + constants.paddingXLarge * 2

                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    property bool editmode: false

                    RowLayout {
                        id: amountLayout
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingXLarge * 2

                        GridLayout {
                            visible: !amountContainer.editmode
                            columns: 2

                            Label {
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                visible: _invoice_amount.isMax
                                font.pixelSize: constants.fontSizeXLarge
                                font.bold: true
                                color: constants.anonTextPrimary
                                text: qsTr('All on-chain funds')
                            }

                            Label {
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                visible: _invoice_amount.isEmpty
                                font.pixelSize: constants.fontSizeXLarge
                                color: constants.anonTextSecondary
                                text: qsTr('not specified')
                            }

                            Label {
                                Layout.alignment: Qt.AlignRight
                                visible: !_invoice_amount.isMax && !_invoice_amount.isEmpty
                                font.pixelSize: constants.fontSizeXXLarge
                                font.family: FixedFont
                                font.bold: true
                                color: constants.anonTextPrimary
                                text: invoice.invoiceType == Invoice.LightningInvoice
                                    ? Config.formatMilliSats(invoice.amount, false)
                                    : Config.formatSats(invoice.amount, false)
                            }

                            Label {
                                Layout.fillWidth: true
                                visible: !_invoice_amount.isMax && !_invoice_amount.isEmpty
                                text: Config.baseUnit
                                color: constants.anonAccent
                                font.pixelSize: constants.fontSizeLarge
                                font.bold: true
                            }

                            Label {
                                id: fiatValue
                                Layout.alignment: Qt.AlignRight
                                visible: Daemon.fx.enabled && !_invoice_amount.isMax && !_invoice_amount.isEmpty
                                font.pixelSize: constants.fontSizeMedium
                                color: constants.anonTextSecondary
                            }

                            Label {
                                Layout.fillWidth: true
                                visible: Daemon.fx.enabled && !_invoice_amount.isMax && !_invoice_amount.isEmpty
                                text: Daemon.fx.fiatCurrency
                                font.pixelSize: constants.fontSizeMedium
                                color: constants.anonTextSecondary
                            }

                        }

                        GridLayout {
                            Layout.fillWidth: true
                            visible: amountContainer.editmode
                            enabled: !(invoice.status == Invoice.Expired && _invoice_amount.isEmpty)

                            columns: 3

                            BtcField {
                                id: amountBtc
                                Layout.preferredWidth: amountFontMetrics.advanceWidth('0') * 14 + leftPadding + rightPadding
                                fiatfield: amountFiat
                                readOnly: amountMax.checked
                                msatPrecision: invoice.invoiceType == Invoice.LightningInvoice
                                color: readOnly
                                    ? constants.anonAccent
                                    : constants.anonTextPrimary
                                onTextAsSatsChanged: {
                                    if (!amountMax.checked)
                                        invoice.amountOverride.copyFrom(textAsSats)
                                }
                                Connections {
                                    target: invoice.amountOverride
                                    function onSatsIntChanged() {
                                        console.log('amountOverride satsIntChanged, sats=' + invoice.amountOverride.satsInt)
                                        if (amountMax.checked)  // amountOverride updated by max amount estimate
                                            amountBtc.text = Config.formatSatsForEditing(invoice.amountOverride.satsInt)
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: amountMax.visible ? false : true
                                Layout.columnSpan: amountMax.visible ? 1 : 2

                                text: Config.baseUnit
                                color: constants.anonAccent
                                font.bold: true
                            }

                            Switch {
                                id: amountMax
                                Layout.fillWidth: true

                                text: qsTr('Max')
                                visible: _canMax
                                checked: false
                                onCheckedChanged: {
                                    if (activeFocus) {
                                        invoice.amountOverride.isMax = checked
                                        if (checked) {
                                            maxAmountMessage.text = ''
                                            invoice.updateMaxAmount()
                                        }
                                    }
                                }
                            }

                            FiatField {
                                id: amountFiat
                                Layout.preferredWidth: amountFontMetrics.advanceWidth('0') * 14 + leftPadding + rightPadding
                                btcfield: amountBtc
                                visible: Daemon.fx.enabled
                                readOnly: amountMax.checked
                                color: readOnly
                                    ? constants.anonAccent
                                    : constants.anonTextPrimary
                            }

                            Label {
                                Layout.columnSpan: 2
                                visible: Daemon.fx.enabled
                                text: Daemon.fx.fiatCurrency
                                color: constants.anonAccent
                                font.bold: true
                            }

                            InfoTextArea {
                                Layout.topMargin: constants.paddingMedium
                                Layout.fillWidth: true
                                Layout.columnSpan: 3
                                id: maxAmountMessage
                                visible: amountMax.checked && text
                                compact: true
                                backgroundColor: constants.anonCardBackground

                                Connections {
                                    target: invoice
                                    function onMaxAmountMessage(message) {
                                        maxAmountMessage.text = message
                                    }
                                }
                            }
                        }
                    }

                }

                Heading {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    visible: invoice.invoiceType == Invoice.LightningInvoice
                    text: qsTr('Technical properties')
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingSmall
                    visible: invoice.invoiceType == Invoice.LightningInvoice
                    text: qsTr('Recipient Pubkey')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: invoice.invoiceType == Invoice.LightningInvoice
                    Layout.preferredHeight: pubkeyLayout.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    RowLayout {
                        id: pubkeyLayout
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingLarge * 2
                        Label {
                            id: pubkeyLabel
                            Layout.fillWidth: true
                            text: 'pubkey' in invoice.lnprops ? invoice.lnprops.pubkey : ''
                            font.family: FixedFont
                            font.pixelSize: constants.fontSizeMedium
                            color: constants.anonTextPrimary
                            wrapMode: Text.Wrap
                        }
                        ToolButton {
                            icon.source: '../../icons/share.png'
                            icon.color: constants.anonAccent
                            enabled: pubkeyLabel.text
                            onClicked: {
                                var dialog = app.genericShareDialog.createObject(app,
                                    { title: qsTr('Node public key'), text: invoice.lnprops.pubkey }
                                )
                                dialog.open()
                            }
                        }
                    }
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingSmall
                    visible: invoice.invoiceType == Invoice.LightningInvoice
                    text: qsTr('Payment hash')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: invoice.invoiceType == Invoice.LightningInvoice
                    Layout.preferredHeight: paymenthashLayout.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    RowLayout {
                        id: paymenthashLayout
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingLarge * 2
                        Label {
                            id: paymenthashLabel
                            Layout.fillWidth: true
                            text: 'payment_hash' in invoice.lnprops ? invoice.lnprops.payment_hash : ''
                            font.family: FixedFont
                            font.pixelSize: constants.fontSizeMedium
                            color: constants.anonTextPrimary
                            wrapMode: Text.Wrap
                        }
                        ToolButton {
                            icon.source: '../../icons/share.png'
                            icon.color: constants.anonAccent
                            enabled: paymenthashLabel.text
                            onClicked: {
                                var dialog = app.genericShareDialog.createObject(app, {
                                    title: qsTr('Payment hash'),
                                    text: invoice.lnprops.payment_hash
                                })
                                dialog.open()
                            }
                        }
                    }
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingSmall
    