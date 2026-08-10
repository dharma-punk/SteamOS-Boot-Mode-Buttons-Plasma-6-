import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property string desktopCommand: "steamos-session-select plasma-x11-persistent"
    readonly property string gameCommand: "steamos-session-select gamescope"

    property bool busy: false
    property bool helperAvailable: true
    property bool statusIsError: false
    property string activeMode: ""
    property string statusText: i18n("Checking SteamOS support...")

    width: Kirigami.Units.gridUnit * 18
    height: Kirigami.Units.gridUnit * 8
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

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

    function errorMessage(data) {
        const stderr = data["stderr"] === undefined ? "" : String(data["stderr"]).trim()
        return stderr.length > 0 ? stderr : i18n("The SteamOS command failed.")
    }

    function checkHelper() {
        statusText = i18n("Checking SteamOS support...")
        helperCheck.connectSource("command -v steamos-session-select")
    }

    function selectMode(modeName, command) {
        if (busy || !helperAvailable) {
            return
        }

        busy = true
        statusIsError = false
        activeMode = modeName
        statusText = i18n("Applying %1 mode...", modeName)
        commandRunner.connectSource(command)
    }

    Plasma5Support.DataSource {
        id: helperCheck
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            root.helperAvailable = root.exitCode(data) === 0
            root.statusIsError = !root.helperAvailable
            root.statusText = root.helperAvailable
                ? i18n("Ready")
                : i18n("steamos-session-select is not available on this system.")
        }
    }

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            const succeeded = root.exitCode(data) === 0
            root.busy = false
            root.statusIsError = !succeeded
            root.statusText = succeeded
                ? i18n("%1 mode selected.", root.activeMode)
                : root.errorMessage(data)
            root.activeMode = ""
        }
    }

    Component.onCompleted: checkHelper()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading {
            text: i18n("Set default boot mode")
            level: 3
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            text: i18n("Choose what SteamOS starts after rebooting.")
            opacity: 0.75
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: i18n("Desktop")
                icon.name: "computer"
                enabled: !root.busy && root.helperAvailable
                Layout.fillWidth: true
                Accessible.name: i18n("Use Desktop mode after rebooting")
                onClicked: root.selectMode(i18n("Desktop"), root.desktopCommand)
            }

            PlasmaComponents.Button {
                text: i18n("Gaming")
                icon.name: "applications-games"
                enabled: !root.busy && root.helperAvailable
                Layout.fillWidth: true
                Accessible.name: i18n("Use Gaming mode after rebooting")
                onClicked: root.selectMode(i18n("Gaming"), root.gameCommand)
            }
        }

        PlasmaComponents.Label {
            text: root.statusText
            color: root.statusIsError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            opacity: 0.85
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Accessible.name: text
        }
    }
}
