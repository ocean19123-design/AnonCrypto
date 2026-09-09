import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    // Spacing
    readonly property int paddingXXSmall: 4
    readonly property int paddingXSmall: 6
    readonly property int paddingSmall: 8
    readonly property int paddingMedium: 12
    readonly property int paddingLarge: 16
    readonly property int paddingXLarge: 20
    readonly property int paddingXXLarge: 28

    // Typography
    readonly property int fontSizeXSmall: 10
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 15
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeXLarge: 22
    readonly property int fontSizeXXLarge: 28

    // Icons
    readonly property int iconSizeXSmall: 12
    readonly property int iconSizeSmall: 16
    readonly property int iconSizeMedium: 24
    readonly property int iconSizeLarge: 32
    readonly property int iconSizeXLarge: 48
    readonly property int iconSizeXXLarge: 64

    readonly property int fingerWidth: 64

    // Anon Flash Theme - Core Colors
    readonly property color anonBackground: "#080B10"
    readonly property color anonCardBackground: "#0D1117"
    readonly property color anonBorder: "#1A1F26"
    readonly property color anonAccent: "#1687FF"
    readonly property color anonAccentLight: "#3A9FFF"
    readonly property color anonAccentDark: "#0D5BB8"
    readonly property color anonTextPrimary: "#FFFFFF"
    readonly property color anonTextSecondary: "#8A93A0"
    readonly property color anonTextTertiary: "#5A6370"
    readonly property color anonPositive: "#00C853"
    readonly property color anonNegative: "#FF3B30"
    readonly property color anonWarning: "#FFB300"
    readonly property color anonError: "#FF3B30"
    readonly property color anonDisabled: "#3A3F46"
    readonly property color anonButtonBackground: "#1687FF"
    readonly property color anonInputBackground: "#0D1117"
    readonly property color anonHoverBackground: "#141920"

    // Map existing Electrum color properties to Anon Flash colors
    property color mutedForeground: anonTextSecondary
    property color darkerBackground: Qt.darker(anonBackground, 1.05)
    property color darkerDialogBackground: anonCardBackground
    property color highlightBackground: Qt.lighter(anonBackground, 1.15)
    property color dialogColor: anonCardBackground
    property color seedTextAreaBackground: anonInputBackground
    property color notificationBackground: Qt.lighter(anonBackground, 1.5)

    // Transaction colors
    property color colorCredit: anonPositive
    property color colorDebit: anonNegative

    // Status colors
    property color colorInfo: anonAccent
    property color colorWarning: anonWarning
    property color colorError: anonError
    property color colorProgress: Qt.rgba(0.4, 0.4, 0.4, 1)
    property color colorDone: anonPositive
    property color colorValidBackground: Qt.rgba(0, 0.35, 0.15, 1)
    property color colorInvalidBackground: Qt.rgba(0.35, 0, 0, 1)
    property color colorAcceptable: anonAccentLight
    property color colorOk: colorDone

    // Lightning colors (kept functional but updated)
    property color colorLightningLocal: anonAccent
    property color colorLightningLocalReserve: anonAccentDark
    property color colorLightningRemote: anonTextSecondary
    property color colorLightningRemoteReserve: anonDisabled
    property color colorChannelOpen: anonPositive

    // Chart colors
    property color colorPiechartTotal: anonAccent
    property color colorPiechartOnchain: anonAccentDark
    property color colorPiechartFrozen: anonDisabled
    property color colorPiechartLightning: anonWarning
    property color colorPiechartLightningFrozen: Qt.darker(anonWarning, 1.20)
    property color colorPiechartUnconfirmed: Qt.darker(anonAccent, 1.50)
    property color colorPiechartUnmatured: anonTextSecondary

    property color colorPiechartParticipant: anonDisabled
    property color colorPiechartSignature: anonWarning

    // Address colors
    property color colorAddressExternal: anonPositive
    property color colorAddressInternal: anonWarning
    property color colorAddressUsed: anonTextTertiary
    property color colorAddressUsedWithBalance: anonTextSecondary
    property color colorAddressFrozen: Qt.rgba(0.35, 0.35, 1, 1)
    property color colorAddressBilling: anonAccentLight
    property color colorAddressSwap: colorAddressBilling
    property color colorAddressAccounting: anonWarning

    function colorAlpha(baseColor, alpha) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha)
    }
}