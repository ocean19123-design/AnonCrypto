import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root

    implicitWidth: balancePane.implicitWidth
    implicitHeight: balancePane.implicitHeight

    property string formattedConfirmedBalance
    property string formattedTotalBalance
    property string formattedTotalBalanceFiat
    property string formattedLightningBalance

    function setBalances() {
        root.formattedConfirmedBalance = Config.formatSats(Daemon.currentWallet.confirmedBalance)
        root.formattedTotalBalance = Config.formatSats(Daemon.currentWallet.totalBalance)
        root.formattedLightningBalance = Config.formatSats(Daemon.currentWallet.lightningBalance)
        if (Daemon.fx.enabled) {
            root.formattedTotalBalanceFiat = Daemon.fx.fiatValue(Daemon.currentWallet.totalBalance, false)
        }
    }

    Rectangle {
        id: balancePane
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: constants.paddingLarge

        implicitHeight: balanceLayout.implicitHeight + constants.paddingXLarge * 2

        radius: constants.paddingLarge
        color: constants.anonCardBackground
        border.width: 1
        border.color: Qt.rgba(0.09, 0.53, 1, 0.3)

        GridLayout {
            id: balanceLayout
            anchors.fill: parent
            anchors.margins: constants.paddingXLarge
            columns: 3
            opacity: Daemon.currentWallet.synchronizing || !Network.isConnected ? 0 : 1

            Label {
                font.pixelSize: constants.fontSizeSmall
                text: qsTr('TOTAL BALANCE')
                color: constants.anonTextSecondary
                font.bold: true
                letterSpacing: 1.5
            }

            Item { Layout.fillWidth: true }

            Item { Layout.preferredWidth: 1 }

            Label {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
                font.pixelSize: constants.fontSizeXXLarge
                font.family: FixedFont
                font.bold: true
                text: formattedTotalBalance
                color: constants.anonTextPrimary
            }
            Label {
                font.pixelSize: constants.fontSizeLarge
                color: constants.anonAccent
                font.bold: true
                text: Config.baseUnit
            }

            Item {
                visible: Daemon.fx.enabled
                Layout.preferredWidth: 1
            }
            Label {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
                visible: Daemon.fx.enabled
                font.pixelSize: constants.fontSizeMedium
                font.family: FixedFont
                color: constants.anonTextSecondary
                text: formattedTotalBalanceFiat + ' ' + Daemon.fx.fiatCurrency
            }
            Item {
                visible: Daemon.fx.enabled
                Layout.preferredWidth: 1
            }

            Rectangle {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: constants.paddingMedium
                Layout.bottomMargin: constants.paddingMedium
                color: constants.anonBorder
            }

            RowLayout {
                Layout.columnSpan: 3
                visible: Daemon.currentWallet.isLightning
                Image {
                    Layout.preferredWidth: constants.iconSizeSmall
                    Layout.preferredHeight: constants.iconSizeSmall
                    source: '../../../icons/lightning.png'
                }
                Label {
                    text: qsTr('Lightning')
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextSecondary
                }
                Item { Layout.fillWidth: true }
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: formattedLightningBalance
                    font.family: FixedFont
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextPrimary
                }
                Label {
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextSecondary
                    text: Config.baseUnit
                }
            }

            RowLayout {
                Layout.columnSpan: 3
                visible: Daemon.currentWallet.isLightning
                Image {
                    Layout.preferredWidth: constants.iconSizeSmall
                    Layout.preferredHeight: constants.iconSizeSmall
                    source: '../../../icons/bitcoin.png'
                }
                Label {
                    text: qsTr('On-chain')
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextSecondary
                }
                Item { Layout.fillWidth: true }
                Label {
                    id: formattedConfirmedBalanceLabel
                    Layout.alignment: Qt.AlignRight
                    text: formattedConfirmedBalance
                    font.family: FixedFont
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextPrimary
                }
                Label {
                    font.pixelSize: constants.fontSizeSmall
                    color: constants.anonTextSecondary
                    text: Config.baseUnit
                }
            }
        }

    }

    Label {
        opacity: Daemon.currentWallet.synchronizing && Network.isConnected ? 1 : 0
        anchors.centerIn: balancePane
        text: Daemon.currentWallet.synchronizingProgress
        color: constants.anonAccent
        font.pixelSize: constants.fontSizeLarge
    }

    Label {
        opacity: !Network.isConnected ? 1 : 0
        anchors.centerIn: balancePane
        text: Network.serverStatus
        color: constants.anonAccent
        font.pixelSize: constants.fontSizeLarge
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            app.stack.push(Qt.resolvedUrl('../BalanceDetails.qml'))
        }
    }

    Connections {
        target: Config
        function onBaseUnitChanged() { setBalances() }
        function onThousandsSeparatorChanged() { setBalances() }
    }

    Connections {
        target: Daemon
        function onWalletLoaded() {
            setBalances()
        }
    }

    Connections {
        target: Daemon.fx
        function onEnabledUpdated() { setBalances() }
        function onQuotesUpdated() { setBalances() }
    }

    Connections {
        target: Daemon.currentWallet
        function onBalanceChanged() {
            setBalances()
        }
    }

    FontMetrics {
        id: fontMetrics
        font: formattedConfirmedBalanceLabel.font
    }

    Component.onCompleted: setBalances()
}