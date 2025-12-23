import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2 as Kirigami

PlasmoidItem {
    width: Kirigami.Units.gridUnit * 18
    height: Kirigami.Units.gridUnit * 6

    // Runs shell commands via Plasma's executable engine (available via Plasma5Support in Plasma 6)
    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName) // one-shot
        }
        function run(cmd) { connectSource(cmd) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        PlasmaExtras.Heading {
            text: "Set default boot"
            level: 3
            Layout.fillWidth: true
        }

        PlasmaComponents3.Label {
            text: "Choose what SteamOS boots into after reboot."
            opacity: 0.75
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Button {
                text: "Set Desktop Boot"
                checkable: false
                Layout.fillWidth: true
                onClicked: exec.run("steamos-session-select plasma-x11-persistent")
            }

            PlasmaComponents3.Button {
                text: "Set Game Boot"
                checkable: false
                Layout.fillWidth: true
                onClicked: exec.run("steamos-session-select gamescope")
            }
        }
    }
}
