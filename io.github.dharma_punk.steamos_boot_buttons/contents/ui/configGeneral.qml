import QtQuick
import org.kde.i18n 1.0
import org.kde.kirigami 2 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    property alias cfg_showHeading: showHeading.checked
    property alias cfg_showDescription: showDescription.checked
    property alias cfg_desktopButtonText: desktopButtonText.text
    property alias cfg_gameButtonText: gameButtonText.text
    property alias cfg_confirmBeforeApply: confirmBeforeApply.checked
    property alias cfg_layoutMode: layoutMode.currentIndex
    property alias cfg_enableNotifications: enableNotifications.checked
    property alias cfg_notifyOnSuccess: notifyOnSuccess.checked
    property alias cfg_notifyOnError: notifyOnError.checked

    property alias cfg_profilePreset: profilePreset.currentIndex
    property alias cfg_customDesktopCommand: customDesktopCommand.text
    property alias cfg_customGameCommand: customGameCommand.text
    property alias cfg_showRebootButton: showRebootButton.checked
    property alias cfg_confirmReboot: confirmReboot.checked
    property alias cfg_rebootCommand: rebootCommand.text

    PlasmaComponents3.CheckBox {
        id: showHeading
        Kirigami.FormData.label: i18n("Visible Elements")
        text: i18n("Show heading")
        Accessible.name: text
    }

    PlasmaComponents3.CheckBox {
        id: showDescription
        text: i18n("Show description")
        Accessible.name: text
    }

    PlasmaComponents3.TextField {
        id: desktopButtonText
        Kirigami.FormData.label: i18n("Button Labels")
        placeholderText: i18n("Set Desktop Boot")
        Accessible.name: i18n("Desktop button label")
    }

    PlasmaComponents3.TextField {
        id: gameButtonText
        placeholderText: i18n("Set Game Boot")
        Accessible.name: i18n("Game button label")
    }

    PlasmaComponents3.ComboBox {
        id: layoutMode
        Kirigami.FormData.label: i18n("Layout")
        model: [i18n("Horizontal"), i18n("Vertical")]
        Accessible.name: i18n("Layout mode")
    }

    PlasmaComponents3.CheckBox {
        id: confirmBeforeApply
        Kirigami.FormData.label: i18n("Confirmation")
        text: i18n("Require click confirmation")
        Accessible.name: text
    }

    PlasmaComponents3.CheckBox {
        id: enableNotifications
        Kirigami.FormData.label: i18n("Notifications")
        text: i18n("Enable passive pop-up notifications")
        Accessible.name: text
    }

    PlasmaComponents3.CheckBox {
        id: notifyOnSuccess
        enabled: enableNotifications.checked
        text: i18n("Notify on success")
        Accessible.name: text
    }

    PlasmaComponents3.CheckBox {
        id: notifyOnError
        enabled: enableNotifications.checked
        text: i18n("Notify on error")
        Accessible.name: text
    }

    PlasmaComponents3.ComboBox {
        id: profilePreset
        Kirigami.FormData.label: i18n("Profile")
        model: [
            i18n("SteamOS Defaults"),
            i18n("Desktop Session Profile"),
            i18n("Custom Commands")
        ]
        Accessible.name: i18n("Boot profile preset")
    }

    PlasmaComponents3.TextField {
        id: customDesktopCommand
        enabled: profilePreset.currentIndex === 2
        Kirigami.FormData.label: i18n("Custom Commands")
        placeholderText: i18n("Desktop command")
        Accessible.name: i18n("Custom desktop command")
    }

    PlasmaComponents3.TextField {
        id: customGameCommand
        enabled: profilePreset.currentIndex === 2
        placeholderText: i18n("Game command")
        Accessible.name: i18n("Custom game command")
    }

    PlasmaComponents3.CheckBox {
        id: showRebootButton
        Kirigami.FormData.label: i18n("Reboot")
        text: i18n("Show reboot action button")
        Accessible.name: text
    }

    PlasmaComponents3.CheckBox {
        id: confirmReboot
        enabled: showRebootButton.checked
        text: i18n("Require reboot confirmation")
        Accessible.name: text
    }

    PlasmaComponents3.TextField {
        id: rebootCommand
        enabled: showRebootButton.checked
        placeholderText: i18n("Reboot command")
        Accessible.name: i18n("Reboot command")
    }
}
