import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property string desktopCommand: "steamosctl set-default-login-mode desktop"
    readonly property string gameCommand: "steamosctl set-default-login-mode game"
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool verticalPanel: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    property bool busy: false
    property bool steamosctlAvailable: false
    property bool statusIsError: false
    property string activeMode: ""
    property string statusText: i18n("Checking SteamOS support…")

    implicitWidth: Kirigami.Units.gridUnit * (inPanel ? (verticalPanel ? 3 : 10) : 18)
    implicitHeight: Kirigami.Units.gridUnit * (inPanel ? (verticalPanel ? 6 : 3) : 8)
    width: implicitWidth
    height: implicitHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
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

    function commandError(data) {
        const stderr = data["stderr"] === undefined ? "" : String(data["stderr"]).trim()
        const stdout = data["stdout"] === undefined ? "" : String(data["stdout"]).trim()

        if (stderr.length > 0) {
            return stderr
        }
        if (stdout.length > 0) {
            return stdout
        }
        return i18n("SteamOS could not change the default boot mode.")
    }

    function checkSupport() {
        statusText = i18n("Checking SteamOS support…")
        supportCheck.connectSource("command -v steamosctl >/dev/null 2>&1")
    }

    function selectMode(modeName, command) {
        if (busy || !steamosctlAvailable) {
            return
        }

        busy = true
        statusIsError = false
        activeMode = modeName
        statusText = i18n("Setting %1 as the default boot mode…", modeName)
        commandRunner.connectSource(command)
    }

    Plasma5Support.DataSource {
        id: supportCheck
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            root.steamosctlAvailable = root.exitCode(data) === 0
            root.statusIsError = !root.steamosctlAvailable
            root.statusText = root.steamosctlAvailable
                ? i18n("Ready. Changes take effect after reboot.")
                : i18n("steamosctl was not found. SteamOS 3.8 or newer is required.")
        }
    }

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const succeeded = root.exitCode(data) === 0
            const completedMode = root.activeMode

            root.busy = false
            root.activeMode = ""
            root.statusIsError = !succeeded

            if (succeeded) {
                root.statusText = i18n("Default boot set to %1. This will take effect after reboot.", completedMode)
            } else {
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
                text: root.verticalPanel ? "" : i18n("Desktop")
                icon.name: "computer"
                enabled: !root.busy && root.steamosctlAvailable
                Layout.fillWidth: true
                Layout.fillHeight: root.inPanel
                Accessible.name: i18n("Set Desktop mode as the default boot mode")
                Accessible.description: i18n("Changes the next and future SteamOS boots to Desktop mode without switching the current session")
                onClicked: root.selectMode(i18n("Desktop mode"), root.desktopCommand)
            }

            PlasmaComponents.Button {
                text: root.verticalPanel ? "" : i18n("Gaming")
                icon.name: "applications-games"
                enabled: !root.busy && root.steamosctlAvailable
                Layout.fillWidth: true
                Layout.fillHeight: root.inPanel
                Accessible.name: i18n("Set Gaming mode as the default boot mode")
                Accessible.description: i18n("Changes the next and future SteamOS boots to Gaming mode without switching the current session")
                onClicked: root.selectMode(i18n("Gaming mode"), root.gameCommand)
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
