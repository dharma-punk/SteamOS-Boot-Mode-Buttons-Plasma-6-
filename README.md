# SteamOS Boot Mode Buttons

**Choose whether SteamOS starts in Desktop Mode or Gaming Mode from a simple Plasma 6 widget.**

SteamOS Boot Mode Buttons is a lightweight front end for Valve's default-login-mode controls. It is useful when you want a docked Steam Deck to start like a desktop computer, then easily return to the normal gaming-first experience later.

The widget:

- shows the current default mode when SteamOS can report it;
- marks the selected mode in the button label;
- avoids rewriting a setting that is already selected;
- verifies a change after SteamOS accepts it;
- works on the desktop and in horizontal or vertical panels.

## Install or update

Enter **Desktop Mode**, open **Konsole**, and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/main/install.sh | bash
```

The same command installs the widget for the first time or updates an existing copy. The installer downloads the latest release, validates the Plasma package, and uses `kpackagetool6` without `sudo`.

After installation, open **Add Widgets**, search for **SteamOS Boot Mode Buttons**, and add it to your desktop or panel. If an existing widget instance still shows the previous version after an update, remove that instance and add it again.

### Install from a downloaded file

[Download the latest `.plasmoid` release](https://github.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/releases/latest/download/SteamOS-Boot-Mode-Buttons.plasmoid), then choose **Add Widgets → Get New Widgets → Install from File…**.

> [!IMPORTANT]
> Do not install the ZIP from GitHub's green **Code → Download ZIP** button. That archive contains the source repository, not the installable Plasma widget.

See [INSTALL.md](INSTALL.md) for additional installation details.

## How it works

When the widget loads, it checks for `steamosctl` and reads the current default:

```bash
steamosctl get-default-login-mode
```

The two buttons use Valve's default-login-mode commands:

```bash
steamosctl set-default-login-mode desktop
steamosctl set-default-login-mode game
```

If the requested mode is already selected, no write is performed. After a change, the widget reads the setting back and verifies the result when the installed SteamOS build supports the query.

The setting applies to a future boot or login. The widget does **not**:

- switch the current Desktop or Gaming session;
- reboot the device;
- restart SDDM or Plasma;
- force X11 or Wayland;
- require root access or a background service.

## Compatibility

| Environment | Status |
| --- | --- |
| Current SteamOS with Plasma 6 and `steamosctl` | Supported |
| Steam Deck LCD and OLED on current SteamOS | Supported |
| Other SteamOS hardware with the same APIs | Expected to work |
| SteamOS without `steamosctl` | Not supported |
| Non-SteamOS Plasma systems | Not supported unless they provide compatible commands |

## Troubleshooting

### The buttons are disabled

The widget disables its actions when it cannot find `steamosctl`. Confirm that you are using a current SteamOS release:

```bash
command -v steamosctl
```

### The widget reports `preferredRepresentation` or still looks outdated

Run the install/update command again. If the widget is already on the desktop or panel, remove that instance and add it again so Plasma loads the updated package.

### Plasma says the package is invalid

Use the install/update command or the direct `.plasmoid` download above. GitHub's source-code ZIP is not an installable widget package.

### Check the installed version

```bash
grep '"Version"' ~/.local/share/plasma/plasmoids/io.github.dharma_punk.steamos_boot_buttons/metadata.json
```

If a problem remains, [open an issue](https://github.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/issues) and include your SteamOS version, the installed widget version, and the exact status or error message.

## Development

The Plasma package lives in:

```text
io.github.dharma_punk.steamos_boot_buttons/
├── metadata.json
└── contents/
    └── ui/
        └── main.qml
```

Validate the source package:

```bash
bash scripts/validate.sh
```

Build the installable `.plasmoid` and checksum:

```bash
bash scripts/package.sh
```

GitHub Actions validate the package, installer, archive structure, Plasma 6 API usage, and absence of legacy or live-session-switch commands. When the widget version changes on `main`, release automation publishes the `.plasmoid`, its SHA-256 checksum, and the installer.

Additional project documents:

- [Changelog](CHANGELOG.md)
- [Package format](docs/PACKAGE_FORMAT.md)
- [KDE Store publication notes](docs/KDE_STORE.md)

## License

[MIT](LICENSE)
