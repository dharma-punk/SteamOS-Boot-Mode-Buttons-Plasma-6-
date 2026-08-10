# SteamOS Boot Mode Buttons

A focused KDE Plasma 6 widget for choosing whether SteamOS starts in Desktop or Gaming mode after rebooting.

## What it does

- **Desktop** runs `steamos-session-select plasma-x11-persistent`.
- **Gaming** runs `steamos-session-select gamescope`.
- Buttons are disabled while a command is running.
- The widget reports success, failure, or a missing SteamOS helper.

The widget intentionally does not execute user-defined commands or include unrelated reboot and notification settings.

## Requirements

- SteamOS with `steamos-session-select`
- KDE Plasma 6
- `kpackagetool6`

## Install

Clone or download this repository, open a terminal in it, and run:

```bash
kpackagetool6 --type Plasma/Applet --install io.github.dharma_punk.steamos_boot_buttons
```

Then add **SteamOS Boot Mode Buttons** from Plasma's widget picker.

To update an existing installation:

```bash
kpackagetool6 --type Plasma/Applet --upgrade io.github.dharma_punk.steamos_boot_buttons
```

To remove it:

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.dharma_punk.steamos_boot_buttons
```

## Validate changes

Run:

```bash
./scripts/validate.sh
```

The script validates the package metadata, checks for obsolete Plasma 5/Qt 5 declarations, and runs `qmllint` when it is installed.

## Compatibility note

SteamOS session identifiers may change between releases. Verify the Desktop and Gaming commands on the SteamOS version you intend to support before publishing a release.

## License

MIT
