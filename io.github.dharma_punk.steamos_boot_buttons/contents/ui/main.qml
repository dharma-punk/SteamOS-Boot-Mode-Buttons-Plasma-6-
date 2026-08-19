import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property string desktopMode: "desktop"
    readonly property string gameMode: "game"
    readonly property string defaultModeQueryCommand: "steamosctl get-default-login-mode"
    readonly property bool inPanel: plasmoid.formFactor === PlasmaCore.Types.Horizontal || plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool verticalPanel: plasmoid.formFactor === PlasmaCore.Types.Vertical

    property bool busy: false
    property bool steamosctlAvailable: false
    property bool statusIsError: false
    property string currentDefaultMode: ""
    property string requestedMode: ""
    property string statusText: i18n("Checking SteamOS support…")

    implicitWidth: Kirigami.Units.gridUnit * (inPanel ? (verticalPanel ? 3 : 10) : 18)
    implicitHeight: Kirigami.Units.gridUnit * (inPanel ? (verticalPanel ? 6 : 3) : 8)
    width: implicitWidth
    height: implicitHeight

    toolTipMainText: i18n("SteamOS Boot Mode Buttons")
    toolTipSubText: statusText

    function exitCode(data) {
        if (data["exit code"] !== undefined) {
            return Number(data["exit code"])
        }
        if (data["exitCode"] !== undefined) {
            return Number(data["exitCode"])
        }
        if (data["exit status"] !== undefined) {
            return Number(data["exit status"])
        }
        return -1
    }

    function stdoutText(data) {
        return data["stdout"] === undefined ? "" : String(data["stdout"]).trim()
    }

    function stderrText(data) {
        return data["stderr"] === undefined ? "" : String(data["stderr"]).trim()
    }

    function commandError(data) {
        const stderr = stderrText(data)
        const message = stderr.length > 0 ? stderr : stdoutText(data)
        return message.length > 0 ? message : i18n("SteamOS could not change the default boot mode.")
    }

    function parseDefaultMode(data) {
        const text = stdoutText(data).toLowerCase()
        if (/\bdesktop\b/.test(text)) {
            return desktopMode
        }
        if (/\bgame\b/.test(text)) {
            return gameMode
        }
        return ""
    }

    function modeLabel(mode) {
        if (mode === desktopMode) {
            return i18n("Desktop mode")
        }
        if (mode === gameMode) {
            return i18n("Gaming mode")
        }
        return i18n("Unknown mode")
    }

    function setModeCommand(mode) {
        return "steamosctl set-default-login-mode " + mode
    }

    function checkSupport() {
        statusText = i18n("Checking SteamOS support…")
        supportCheck.connectSource("command -v steamosctl >/dev/null 2>&1")
    }

    function refreshDefaultMode() {
        busy = true
        defaultModeQuery.connectSource(defaultModeQueryCommand)
    }

    function selectMode(mode) {
        if (busy || !steamosctlAvailable) {
            return
        }

        if (currentDefaultMode === mode) {
            statusIsError = false
            statusText = i18n("%1 is already the default. No change was made.", modeLabel(mode))
            return
        }

        busy = true
        statusIsError = false
        requestedMode = mode
        statusText = i18n("Setting %1 as the default boot mode…", modeLabel(mode))
        commandRunner.connectSource(setModeCommand(mode))
    }

    Plasma5Support.DataSource {
        id: supportCheck
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            root.steamosctlAvailable = root.exitCode(data) === 0
            root.statusIsError = !root.steamosctlAvailable

            if (root.steamosctlAvailable) {
                root.statusText = i18n("Reading current default boot mode…")
                root.requestedMode = ""
                root.refreshDefaultMode()
            } else {
                root.statusText = i18n("steamosctl was not found. A current SteamOS release with steamosctl is required.")
            }
        }
    }

    Plasma5Support.DataSource {
        id: defaultModeQuery
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const succeeded = root.exitCode(data) === 0
            const reportedMode = succeeded ? root.parseDefaultMode(data) : ""
            const expectedMode = root.requestedMode

            if (reportedMode.length > 0) {
                root.currentDefaultMode = reportedMode
            }

            if (expectedMode.length > 0) {
                root.busy = false
                root.requestedMode = ""

                if (reportedMode === expectedMode) {
                    root.statusIsError = false
                    root.statusText = i18n("Default boot verified as %1. The change applies on the next boot/login.", root.modeLabel(expectedMode))
                } else if (!succeeded || reportedMode.length === 0) {
                    root.currentDefaultMode = expectedMode
                    root.statusIsError = false
                    root.statusText = i18n("SteamOS accepted %1 as the default, but this SteamOS build could not report the setting back for verification.", root.modeLabel(expectedMode))
                } else {
                    root.statusIsError = true
                    root.statusText = i18n("SteamOS reported %1 after %2 was requested.", root.modeLabel(reportedMode), root.modeLabel(expectedMode))
                }
                return
            }

            root.busy = false
            if (reportedMode.length > 0) {
                root.statusIsError = false
                root.statusText = i18n("Current default: %1. Changes apply on the next boot/login.", root.modeLabel(reportedMode))
            } else {
                root.statusIsError = false
                root.statusText = i18n("Ready. This SteamOS build could not report the current default, so changes cannot be pre-checked.")
            }
        }
    }

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const succeeded = root.exitCode(data) === 0

            if (succeeded) {
                root.statusIsError = false
                root.statusText = i18n("SteamOS accepted the change. Verifying…")
                root.refreshDefaultMode()
            } else {
                root.busy = false
                root.requestedMode = ""
                root.statusIsError = true
                root.statusText = root.commandError(data)
            }
        }
    }

    Component.onCompleted: checkSupport()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading {
            visible: !root.inPanel
            text: i18n("Default boot mode")
            level: 3
            Layout.fillWidth: true
            Accessible.name: text
        }

        PlasmaComponents.Label {
            visible: !root.inPanel
            text: i18n("Choose whether SteamOS starts in Desktop or Gaming mode after rebooting.")
            opacity: 0.75
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Accessible.name: text
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: root.inPanel
            columns: root.verticalPanel ? 1 : 2
            columnSpacing: Kirigami.Units.smallSpacing
            rowSpacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: root.verticalPanel ? "" : (root.currentDefaultMode === root.desktopMode ? i18n("Desktop ✓") : i18n("Desktop"))
                icon.name: "computer"
                enabled: !root.busy && root.steamosctlAvailable
                Layout.fillWidth: true
                Layout.fillHeight: root.inPanel
                Accessible.name: i18n("Set Desktop mode as the default boot mode")
                Accessible.description: i18n("Uses SteamOS default-login configuration and does not invoke a live session-switch command")
                onClicked: root.selectMode(root.desktopMode)
            }

            PlasmaComponents.Button {
                text: root.verticalPanel ? "" : (root.currentDefaultMode === root.gameMode ? i18n("Gaming ✓") : i18n("Gaming"))
                icon.name: "applications-games"
                enabled: !root.busy && root.steamosctlAvailable
                Layout.fillWidth: true
                Layout.fillHeight: root.inPanel
                Accessible.name: i18n("Set Gaming mode as the default boot mode")
                Accessible.description: i18n("Uses SteamOS default-login configuration and does not invoke a live session-switch command")
                onClicked: root.selectMode(root.gameMode)
            }
        }

        PlasmaComponents.Label {
            visible: !root.inPanel
            text: root.statusText
            color: root.statusIsError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            opacity: 0.85
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Accessible.name: text
        }
    }
}
