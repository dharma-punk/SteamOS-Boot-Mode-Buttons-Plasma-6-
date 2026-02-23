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
    property int requestCounter: 0
    property var latestSources: ({ action: "", dependency: "" })
    property var latestAction: ({ key: "", command: "" })

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

    function isSafeCommand(command) {
        return !/[;&|`$<>\n\r]/.test(command)
    }

    function actionDisplayName(actionKey) {
        if (actionKey === "desktop") {
            return i18n("Desktop")
        }
        if (actionKey === "game") {
            return i18n("Game")
        }
        if (actionKey === "reboot") {
            return i18n("Reboot")
        }
        return i18n("Action")
    }

    function actionDetailText(actionKey, command, message) {
        return i18n("%1 command (%2): %3", actionDisplayName(actionKey), command, message)
    }

    function shouldCheckSteamHelper() {
        return commandNeedsSteamHelper(effectiveDesktopCommand()) || commandNeedsSteamHelper(effectiveGameCommand())
    }

    function nextRequestSource(command) {
        requestCounter += 1
        return "CODEX_REQUEST_" + requestCounter + "=1; " + command
    }

    function refreshDependencyStatus() {
        if (executionStatus === statusRunning) {
            dependencyCheckQueued = true
            return
        }

        dependencyCheckQueued = false
        if (shouldCheckSteamHelper()) {
            latestSources.dependency = nextRequestSource("command -v steamos-session-select >/dev/null 2>&1")
            exec.run(latestSources.dependency, "dependency")
        } else if (statusMessage === i18n("Required tool is unavailable")) {
            setStatus(statusIdle, i18n("Ready"), "")
            latestSources.dependency = ""
        }
    }

    function scheduleDependencyStatusRefresh() {
        dependencyRefreshDebounce.restart()
    }

    function setStatus(status, message, details) {
        executionStatus = status
        statusMessage = message
        statusDetails = details === undefined ? "" : details
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
            setStatus(statusIdle, i18n("Press the same button again to confirm"), "")
            return
        }

        if (!isSafeCommand(command)) {
            pendingActionKey = ""
            setStatus(statusError, i18n("Unsafe command blocked"), i18n("%1 command contains restricted shell characters: %2", actionDisplayName(actionKey), command))
            notify(i18n("SteamOS action blocked: unsafe command"), true)
            return
        }

        pendingActionKey = ""
        setStatus(statusRunning, i18n("Applying change..."), "")
        latestAction = { key: actionKey, command: command }
        latestSources.action = nextRequestSource(command)
        exec.run(latestSources.action, "action")
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        property var sourceKinds: ({})

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const sourceKind = sourceKinds[sourceName]
            delete sourceKinds[sourceName]

            if (sourceKind === undefined) {
                return
            }

            const exitCode = parseExitCode(data)
            const stdout = parseOutput(data, "stdout")
            const stderr = parseOutput(data, "stderr")
            const message = stdout !== "" ? stdout : (stderr !== "" ? stderr : i18n("No output"))

            if (sourceKind === "dependency") {
                if (sourceName !== latestSources.dependency) {
                    return
                }

                if (exitCode !== 0 && executionStatus !== statusRunning) {
                    setStatus(statusError, i18n("Required tool is unavailable"), i18n("steamos-session-select was not found in PATH."))
                }
                return
            }

            if (sourceKind !== "action" || sourceName !== latestSources.action) {
                return
            }

            if (exitCode === 0) {
                setStatus(statusSuccess, i18n("Action completed successfully"), actionDetailText(latestAction.key, latestAction.command, message))
                notify(i18n("SteamOS action completed successfully"), false)
            } else {
                setStatus(statusError, i18n("Action failed"), actionDetailText(latestAction.key, latestAction.command, message))
                notify(i18n("SteamOS action failed"), true)
            }

            if (dependencyCheckQueued) {
                refreshDependencyStatus()
            }
        }

        function run(cmd, kind) {
            sourceKinds[cmd] = kind
            connectSource(cmd)
        }
    }

    Timer {
        id: dependencyRefreshDebounce
        interval: 200
        repeat: false
        onTriggered: refreshDependencyStatus()
    }

    Component.onCompleted: {
        refreshDependencyStatus()
    }

    Connections {
        target: Plasmoid.configuration

        function onProfilePresetChanged() { scheduleDependencyStatusRefresh() }
        function onCustomDesktopCommandChanged() { scheduleDependencyStatusRefresh() }
        function onCustomGameCommandChanged() { scheduleDependencyStatusRefresh() }
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
