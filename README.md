# SteamOS Boot Mode Buttons

**Choose whether SteamOS boots into Desktop Mode or Gaming Mode — without changing or restarting the session you are using right now.**

A lightweight KDE Plasma 6 widget for SteamOS 3.8+ that puts Valve's default-login-mode controls behind two simple buttons.

## Why use it?

SteamOS normally makes Gaming Mode the center of the experience. That is great for handheld and couch gaming, but it can be annoying if you also use your Steam Deck or SteamOS machine like a regular computer.

SteamOS Boot Mode Buttons is useful when you want to:

- **Use a docked Steam Deck like a desktop PC** and boot straight into Desktop Mode.
- **Return to the normal console-style experience** and make Gaming Mode the default again.
- **Switch between desktop-first and gaming-first setups** without memorizing terminal commands.
- Avoid the older persistent-session method that could refresh/restart the desktop or force a specific X11 session.

## What it does

The widget has two actions:

- **Desktop** → make Desktop Mode the default for future boots.
- **Gaming** → make Gaming Mode the default for future boots.

Under the hood it uses Valve's current SteamOS management interface:

```bash
steamosctl set-default-login-mode desktop
steamosctl set-default-login-mode game
```

The choice takes effect on a future boot/login. Pressing a button does **not** immediately switch sessions, reboot the device, restart SDDM, or force X11/Wayland.

## Features

- Desktop and Gaming default-boot buttons.
- Uses current `steamosctl` instead of legacy `steamos-session-select`.
- Non-disruptive: keeps the current desktop/session running.
- Desktop-session neutral: SteamOS remains in control of X11 vs Wayland.
- Detects whether `steamosctl` is available before enabling actions.
- Clear ready, working, success, and error status messages.
- Prevents overlapping command runs.
- Adapts to desktop, horizontal-panel, and vertical-panel placement.
- Native Plasma 6 QML package with accessibility labels and descriptions.
- No `sudo`, custom shell commands, reboot button, or background service.

# Install

## Recommended — paste one command

On your Steam Deck, enter **Desktop Mode**, open **Konsole**, and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/main/install.sh | bash
```

The installer:

1. Downloads the **latest real widget release** directly from GitHub.
2. Saves it to a temporary filename so browser naming does not matter.
3. Verifies that it is a readable Plasma package with the expected files and plugin ID.
4. Updates an existing copy when possible, or cleanly reinstalls it if necessary.
5. Installs it with `kpackagetool6` without `sudo`.

After it says **Installed successfully**, open **Add Widgets**, search for **SteamOS Boot Mode Buttons**, and add it to your desktop or panel.

## GUI install — direct widget download

**[⬇️ Download the latest SteamOS Boot Mode Buttons widget](https://github.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/releases/latest/download/SteamOS-Boot-Mode-Buttons.plasmoid)**

Then:

1. Open **Add Widgets** in Desktop Mode.
2. Choose **Get New Widgets** → **Install from File…**.
3. Select `SteamOS-Boot-Mode-Buttons.plasmoid`.
4. Add the widget from the widget picker.

> [!IMPORTANT]
> **Do not use GitHub's green `Code` → `Download ZIP` button to install the widget.** That ZIP contains the entire source repository for developers, not the Plasma widget package. Plasma can correctly reject that source ZIP as an invalid package.

For more installation and troubleshooting details, see [INSTALL.md](INSTALL.md).

## How the widget behaves

### Set Desktop boot

```text
Click Desktop
     ↓
SteamOS records Desktop as the default login mode
     ↓
Your current session stays open
     ↓
Reboot whenever you want
     ↓
SteamOS starts in Desktop Mode
```

### Set Gaming boot

```text
Click Gaming
     ↓
SteamOS records Gaming as the default login mode
     ↓
Your current session stays open
     ↓
Reboot whenever you want
     ↓
SteamOS starts in Gaming Mode
```

## What it intentionally does not do

This widget does not:

- switch you out of the session you are currently using;
- automatically reboot;
- restart SDDM or Plasma;
- force Plasma X11 or Plasma Wayland;
- modify arbitrary system files;
- run user-entered shell commands;
- require root access.

It is intentionally a small GUI for SteamOS's default boot-mode setting.

## Compatibility

| Environment | Status |
| --- | --- |
| SteamOS 3.8+ / Plasma 6 | Supported target |
| Steam Deck LCD / OLED on current SteamOS | Supported target |
| Other current SteamOS hardware | API-compatible target |
| SteamOS releases without `steamosctl` | Not supported by v2 |
| Non-SteamOS Plasma systems | Not supported unless they provide compatible `steamosctl` behavior |

## Troubleshooting

### `No such file: ~/Downloads/SteamOS-Boot-Mode-Buttons.plasmoid`

That means the file is **not actually saved under that exact filename**. It is a filename/path problem, not a widget-package validation error.

Use the recommended one-command installer above and it will download the package itself.

To see what your browser actually saved:

```bash
ls -lh ~/Downloads | grep -i 'SteamOS-Boot-Mode-Buttons'
```

### `Package is not considered valid`

Make sure you did **not** select GitHub's repository/source ZIP from **Code → Download ZIP**.

Use either:

- the one-command installer above, or
- the direct `.plasmoid` download link above.

## For developers

The installable Plasma package lives in:

```text
io.github.dharma_punk.steamos_boot_buttons/
├── metadata.json
└── contents/
    └── ui/
        └── main.qml
```

Validate it:

```bash
bash scripts/validate.sh
```

Build the release package:

```bash
bash scripts/package.sh
```

The resulting `.plasmoid` is ZIP-formatted internally and contains `metadata.json` and `contents/` at its archive root, matching KDE's Plasma 6 widget package structure.

GitHub Actions validate package metadata and archive structure on every change. Release automation publishes the installable `.plasmoid` plus its SHA-256 checksum whenever the widget version is bumped on `main`.

See [docs/KDE_STORE.md](docs/KDE_STORE.md) for KDE Store publication notes.

## License

MIT
