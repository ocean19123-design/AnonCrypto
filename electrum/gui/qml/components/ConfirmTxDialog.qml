import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.electrum 1.0

import "controls"

ElDialog {
    id: dialog

    required property QtObject finalizer
    required property var satoshis  // type: Amount
    property string address
    property string message
    property bool showOptions: true
    property alias amountLabelText: amountLabel.text
    property alias sendButtonText: sendButton.text

    title: qsTr('Transaction Fee')
    iconSource: Qt.resolvedUrl('../../icons/question.png')

    // copy these to finalizer
    onAddressChanged: finalizer.address = address
    onSatoshisChanged: finalizer.amount = satoshis

    width: parent.width
    height: parent.height
    padding: 0

    function updateAmountText() {
        if (finalizer.valid) {
            btcValue.text = Config.formatSats(finalizer.effectiveAmount, false)
            fiatValue.text = Daemon.fx.enabled
                ? Daemon.fx.fiatValue(finalizer.effectiveAmount, false)
                : ''
        } else {
            btcValue.text = Config.formatSats(finalizer.amount, false)
            fiatValue.text = Daemon.fx.enabled
                ? Daemon.fx.fiatValue(finalizer.amount, false)
                : ''
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            leftMargin: constants.paddingLarge
            rightMargin: constants.paddingLarge

            contentHeight: rootLayout.height
            clip: true
            interactive: height < contentHeight

            GridLayout {
                id: rootLayout
                width: parent.width

                columns: 2

                Label {
                    id: amountLabel
                    Layout.columnSpan: 2
                    text: qsTr('Amount to send')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: amountPane.height
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    ColumnLayout {
                        id: amountPane
                        width: parent.width
                        spacing: 0

                        Item { Layout.preferredHeight: constants.paddingLarge }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: constants.paddingLarge
                            Layout.rightMargin: constants.paddingLarge
                            spacing: constants.paddingSmall

                            Label {
                                id: btcValue
                                Layout.alignment: Qt.AlignRight
                                font.pixelSize: constants.fontSizeXXLarge
                                font.family: FixedFont
                                font.bold: true
                                color: constants.anonTextPrimary
                            }

                            Label {
                                Layout.fillWidth: true
                                text: Config.baseUnit
                                color: constants.anonAccent
                                font.pixelSize: constants.fontSizeLarge
                                font.bold: true
                                Layout.alignment: Qt.AlignBottom
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: constants.paddingLarge
                            Layout.rightMargin: constants.paddingLarge
                            Layout.bottomMargin: constants.paddingLarge
                            visible: Daemon.fx.enabled
                            spacing: constants.paddingSmall

                            Label {
                                id: fiatValue
                                Layout.alignment: Qt.AlignRight
                                font.pixelSize: constants.fontSizeMedium
                                color: constants.anonTextSecondary
                            }

                            Label {
                                Layout.fillWidth: true
                                text: Daemon.fx.fiatCurrency
                                font.pixelSize: constants.fontSizeMedium
                                color: constants.anonTextSecondary
                            }
                        }
                    }

                    Component.onCompleted: updateAmountText()
                    Connections {
                        target: finalizer
                        function onEffectiveAmountChanged() {
                            updateAmountText()
                        }
                        function onValidChanged() {
                            updateAmountText()
                        }
                    }
                }

                Label {
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    text: qsTr('Fee')
                    color: constants.anonTextSecondary
                    font.bold: true
                    font.pixelSize: constants.fontSizeSmall
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: feepicker.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder

                    FeePicker {
                        id: feepicker
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingLarge * 2
                        finalizer: dialog.finalizer

                        Label {
                            visible: !finalizer.extraFee.isEmpty
                            text: qsTr('Extra fee')
                            color: constants.anonTextSecondary
                        }

                        FormattedAmount {
                            visible: !finalizer.extraFee.isEmpty
                            amount: finalizer.extraFee
                        }
                    }
                }

                ToggleLabel {
                    id: optionstoggle
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    labelText: qsTr('Options')
                    color: constants.anonAccent
                    visible: showOptions
                }

                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: optionslayout.height + constants.paddingLarge * 2
                    radius: constants.paddingLarge
                    color: constants.anonCardBackground
                    border.width: 1
                    border.color: constants.anonBorder
                    visible: optionstoggle.visible && !optionstoggle.collapsed

                    GridLayout {
                        id: optionslayout
                        anchors.centerIn: parent
                        width: parent.width - constants.paddingLarge * 2
                        columns: 2

                        ElCheckBox {
                            Layout.fillWidth: true
                            text: qsTr('Use multiple change addresses')
                            onCheckedChanged: {
                                if (activeFocus) {
                                    Daemon.currentWallet.multipleChange = checked
                                    finalizer.doUpdate()
                                }
                            }
                            Component.onCompleted: {
                                checked = Daemon.currentWallet.multipleChange
                            }
                        }

                        HelpButton {
                            heading: qsTr('Use multiple change addresses')
                            helptext: [qsTr('In some cases, use up to 3 change addresses in order to break up large coin amounts and obfuscate the recipient address.'),
                                       qsTr('This may result in higher transactions fees.')].join(' ')
                        }

                        ElCheckBox {
                            Layout.fillWidth: true
                            text: Config.shortDescFor('WALLET_COIN_CHOOSER_OUTPUT_ROUNDING')
                            onCheckedChanged: {
                                if (activeFocus) {
                                    Config.outputValueRounding = checked
                                    finalizer.doUpdate()
                                }
                            }
                            Component.onCompleted: {
                                checked = Config.outputValueRounding
                            }
                        }

                        HelpButton {
                            heading: Config.shortDescFor('WALLET_COIN_CHOOSER_OUTPUT_ROUNDING')
                            helptext: Config.longDescFor('WALLET_COIN_CHOOSER_OUTPUT_ROUNDING')
                        }

                    }
                }

                InfoTextArea {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.topMargin: constants.paddingLarge
                    Layout.bottomMargin: constants.paddingLarge
                    visible: finalizer.warning != ''
                    text: finalizer.warning
                    iconStyle: InfoTextArea.IconStyle.Warn
                    backgroundColor: constants.anonCardBackground
                }

                ToggleLabel {
                    id: inputs_label
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    visible: finalizer.valid

                    labelText: qsTr('Inputs (%1)').arg(finalizer.inputs.length)
                    color: constants.anonAccent
                }

                Repeater {
                    model: inputs_label.collapsed
                        ? undefined
                        : finalizer.inputs
                    delegate: TxInput {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        visible: finalizer.valid
                        backgroundColor: constants.anonCardBackground

                        idx: index
                        model: modelData
                    }
                }

                ToggleLabel {
                    id: outputs_label
                    Layout.columnSpan: 2
                    Layout.topMargin: constants.paddingMedium
                    visible: finalizer.valid

                    labelText: qsTr('Outputs (%1)').arg(finalizer.outputs.length)
                    color: constants.anonAccent
                }

                Repeater {
                    model: outputs_label.collapsed
                        ? undefined
                        : finalizer.outputs
                    delegate: TxOutput {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        visible: finalizer.valid
                        backgroundColor: constants.anonCardBackground

                        allowShare: false
                        allowClickAddress: false

                        idx: index
                        model: modelData
                    }
                }

            }
        }

        DialogButtonContainer {
            Layout.fillWidth: true

            FlatButton {
                id: sendButton
                Layout.fillWidth: true
                Layout.preferredHeight: constants.paddingXXLarge * 2
                text: (Daemon.currentWallet.isWatchOnly || !Daemon.currentWallet.canSignWithoutCosigner)
                        ? qsTr('Finalize...')
                        : qsTr('Pay...')
                icon.source: '../../icons/confirmed.png'
                icon.color: constants.anonAccent
                enabled: finalizer.valid
                onClicked: doAccept()
            }
        }
    }

    onClosed: doReject()
}