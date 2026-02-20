import QtQuick
import QtQuick.Layouts
import org.kde.i18n 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2 as Kirigami

PlasmoidItem {
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool verticalPanel: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int layoutHorizontal: 0
    readonly property int statusIdle: 0
    readonly property int statusRunning: 1
    readonly property int statusSuccess: 2
    readonly property int statusError: 3

    readonly property string defaultDesktopCommand: "steamos-session-select plasma-x11-persistent"
    readonly property string desktopProfileCommand: "steamos-session-select plasma"
    readonly property string defaultGameCommand: "steamos-session-select gamescope"
    readonly property string defaultRebootCommand: "systemctl reboot"

    width: Kirigami.Units.gridUnit * (inPanel ? 12 : 18)
    height: Kirigami.Units.gridUnit * (inPanel ? 5 : 10)

    property int executionStatus: statusIdle
    property string statusMessage: i18n("Ready")
    property string statusDetails: ""
    property string pendingActionKey: ""
    property bool dependencyCheckQueued: false

    function parseExitCode(data) {
        if (data["exit code"] !== undefined) {
            return Number(data["exit code"])
        }
        if (data["exitCode"] !== undefined) {
            return Number(data["exitCode"])
        }
        if (data["exit status"] !== undefined) {
            return Number(data["exit status"])
        }
        return 0
    }

    function parseOutput(data, key) {
        if (data[key] === undefined || data[key] === null) {
            return ""
        }
        return String(data[key]).trim()
    }

    function normalizedCommand(value, fallback) {
        const cmd = String(value === undefined || value === null ? "" : value).trim()
        return cmd.length > 0 ? cmd : fallback
    }

    function commandNeedsSteamHelper(command) {
        return command.indexOf("steamos-session-select") !== -1
    }

    function shouldCheckSteamHelper() {
        return commandNeedsSteamHelper(effectiveDesktopCommand()) || commandNeedsSteamHelper(effectiveGameCommand())
    }

    function refreshDependencyStatus() {
        if (executionStatus === statusRunning) {
            dependencyCheckQueued = true
            return
        }

        dependencyCheckQueued = false
        if (shouldCheckSteamHelper()) {
            exec.run("command -v steamos-session-select >/dev/null 2>&1")
        } else if (statusMessage === i18n("Required tool is unavailable")) {
            executionStatus = statusIdle
            statusMessage = i18n("Ready")
            statusDetails = ""
        }
    }

    function notify(text, isError) {
        if (!Plasmoid.configuration.enableNotifications) {
            return
        }
        if (isError && !Plasmoid.configuration.notifyOnError) {
            return
        }
        if (!isError && !Plasmoid.configuration.notifyOnSuccess) {
            return
        }
        if (typeof Plasmoid.showPassiveNotification === "function") {
            Plasmoid.showPassiveNotification(text)
        }
    }

    function effectiveDesktopCommand() {
        if (Plasmoid.configuration.profilePreset === 2) {
            return normalizedCommand(Plasmoid.configuration.customDesktopCommand, defaultDesktopCommand)
        }
        if (Plasmoid.configuration.profilePreset === 1) {
            return desktopProfileCommand
        }
        return defaultDesktopCommand
    }

    function effectiveGameCommand() {
        if (Plasmoid.configuration.profilePreset === 2) {
            return normalizedCommand(Plasmoid.configuration.customGameCommand, defaultGameCommand)
        }
        return defaultGameCommand
    }

    function effectiveRebootCommand() {
        return normalizedCommand(Plasmoid.configuration.rebootCommand, defaultRebootCommand)
    }

    function runAction(actionKey, command, confirmRequired) {
        if (executionStatus === statusRunning) {
            return
        }

        if (confirmRequired && pendingActionKey !== actionKey) {
            pendingActionKey = actionKey
            statusMessage = i18n("Press the same button again to confirm")
            statusDetails = ""
            executionStatus = statusIdle
            return
        }

        pendingActionKey = ""
        executionStatus = statusRunning
        statusMessage = i18n("Applying change...")
        statusDetails = ""
        exec.run(command)
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const exitCode = parseExitCode(data)
            const stdout = parseOutput(data, "stdout")
            const stderr = parseOutput(data, "stderr")
            const message = stdout !== "" ? stdout : (stderr !== "" ? stderr : i18n("No output"))

            if (sourceName === "command -v steamos-session-select >/dev/null 2>&1") {
                if (exitCode !== 0 && executionStatus !== statusRunning) {
                    executionStatus = statusError
                    statusMessage = i18n("Required tool is unavailable")
                    statusDetails = i18n("steamos-session-select was not found in PATH.")
                }
                return
            }

            if (exitCode === 0) {
                executionStatus = statusSuccess
                statusMessage = i18n("Action completed successfully")
                statusDetails = message
                notify(i18n("SteamOS action completed successfully"), false)
            } else {
                executionStatus = statusError
                statusMessage = i18n("Action failed")
                statusDetails = message
                notify(i18n("SteamOS action failed"), true)
            }

            if (dependencyCheckQueued) {
                refreshDependencyStatus()
            }
        }

        function run(cmd) {
            connectSource(cmd)
        }
    }

    Component.onCompleted: {
        refreshDependencyStatus()
    }

    Connections {
        target: Plasmoid.configuration

        function onProfilePresetChanged() { refreshDependencyStatus() }
        function onCustomDesktopCommandChanged() { refreshDependencyStatus() }
        function onCustomGameCommandChanged() { refreshDependencyStatus() }
        }

        function run(cmd) {
            connectSource(cmd)
        }
    }

    Component.onCompleted: {
        exec.run("command -v steamos-session-select >/dev/null 2>&1")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        PlasmaExtras.Heading {
            visible: !inPanel && Plasmoid.configuration.showHeading
            text: i18n("Set default boot")
            level: 3
            Layout.fillWidth: true
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            visible: !inPanel && Plasmoid.configuration.showDescription
            text: i18n("Choose what SteamOS boots into after reboot.")
            opacity: 0.75
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Accessible.name: text
        }

        GridLayout {
            Layout.fillWidth: true
            columns: {
                if (inPanel) {
                    return verticalPanel ? 1 : 2
                }
                return Plasmoid.configuration.layoutMode === layoutHorizontal ? 2 : 1
            }
            columnSpacing: Kirigami.Units.smallSpacing
            rowSpacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                text: inPanel ? i18n("Desktop") : (Plasmoid.configuration.desktopButtonText || i18n("Set Desktop Boot"))
                icon.name: "computer"
                enabled: executionStatus !== statusRunning
                Layout.fillWidth: true
                Accessible.name: i18n("Set desktop mode as default boot")
                Accessible.description: i18n("Runs configured desktop selection command")
                onClicked: runAction("desktop", effectiveDesktopCommand(), Plasmoid.configuration.confirmBeforeApply)
            }

            PlasmaComponents3.Button {
                text: inPanel ? i18n("Game") : (Plasmoid.configuration.gameButtonText || i18n("Set Game Boot"))
                icon.name: "applications-games"
                enabled: executionStatus !== statusRunning
                Layout.fillWidth: true
                Accessible.name: i18n("Set gaming mode as default boot")
                Accessible.description: i18n("Runs configured game selection command")
                onClicked: runAction("game", effectiveGameCommand(), Plasmoid.configuration.confirmBeforeApply)
            }

            PlasmaComponents3.Button {
                visible: Plasmoid.configuration.showRebootButton
                text: i18n("Reboot Now")
                icon.name: "system-reboot"
                enabled: executionStatus !== statusRunning
                Layout.fillWidth: true
                Layout.columnSpan: inPanel && !verticalPanel ? 2 : 1
                Accessible.name: i18n("Reboot the system now")
                Accessible.description: i18n("Runs configured reboot command")
                onClicked: runAction("reboot", effectiveRebootCommand(), Plasmoid.configuration.confirmReboot)
            }

            PlasmaComponents3.Button {
                visible: Plasmoid.configuration.showRebootButton
                text: i18n("Reboot Now")
                icon.name: "system-reboot"
                enabled: executionStatus !== statusRunning
                Layout.fillWidth: true
                Layout.columnSpan: inPanel && !verticalPanel ? 2 : 1
                Accessible.name: i18n("Reboot the system now")
                Accessible.description: i18n("Runs configured reboot command")
                onClicked: runAction("reboot", effectiveRebootCommand(), Plasmoid.configuration.confirmReboot)
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            visible: !inPanel
            wrapMode: Text.WordWrap
            color: executionStatus === statusError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            Accessible.name: text
            text: {
                if (executionStatus === statusRunning) {
                    return i18n("Status: Running")
                }
                if (executionStatus === statusSuccess) {
                    return i18n("Status: Success")
                }
                if (executionStatus === statusError) {
                    return i18n("Status: Error")
                }
                return i18n("Status: Idle")
            }

            PlasmaComponents3.Button {
                visible: Plasmoid.configuration.showRebootButton
                text: i18n("Reboot Now")
                icon.name: "system-reboot"
                enabled: executionStatus !== statusRunning
                Layout.fillWidth: true
                Layout.columnSpan: inPanel && !verticalPanel ? 2 : 1
                Accessible.name: i18n("Reboot the system now")
                Accessible.description: i18n("Runs configured reboot command")
                onClicked: runAction("reboot", effectiveRebootCommand(), Plasmoid.configuration.confirmReboot)
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            visible: !inPanel
            wrapMode: Text.WordWrap
            color: executionStatus === statusError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            Accessible.name: text
            text: {
                if (executionStatus === statusRunning) {
                    return i18n("Status: Running")
                }
                if (executionStatus === statusSuccess) {
                    return i18n("Status: Success")
                }
                if (executionStatus === statusError) {
                    return i18n("Status: Error")
                }
                return i18n("Status: Idle")
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.85
            text: statusMessage
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            visible: !inPanel && statusDetails.length > 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: statusDetails
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.85
            text: statusMessage
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            visible: !inPanel && statusDetails.length > 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: statusDetails
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            visible: !inPanel
            wrapMode: Text.WordWrap
            color: executionStatus === statusError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            Accessible.name: text
            text: {
                if (executionStatus === statusRunning) {
                    return i18n("Status: Running")
                }
                if (executionStatus === statusSuccess) {
                    return i18n("Status: Success")
                }
                if (executionStatus === statusError) {
                    return i18n("Status: Error")
                }
                return i18n("Status: Idle")
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.85
            text: statusMessage
            Accessible.name: text
        }

        PlasmaComponents3.Label {
            visible: !inPanel && statusDetails.length > 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: statusDetails
            Accessible.name: text
        }
    }
}
