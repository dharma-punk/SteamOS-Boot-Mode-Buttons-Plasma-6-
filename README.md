# SteamOS Boot Mode Buttons

**Choose whether SteamOS boots into Desktop Mode or Gaming Mode from a simple Plasma 6 widget.**

SteamOS Boot Mode Buttons is a lightweight front end for Valve's default-login-mode controls. It is aimed at Steam Deck and other current SteamOS systems where you sometimes want a desktop-first machine and sometimes want the normal gaming-first experience.

## Why use it?

SteamOS normally makes Gaming Mode the center of the experience. That is great for handheld and couch gaming, but it can be annoying if you also use your Steam Deck or SteamOS machine like a regular computer.

SteamOS Boot Mode Buttons is useful when you want to:

- **Use a docked Steam Deck like a desktop PC** and boot straight into Desktop Mode.
- **Return to the normal console-style experience** and make Gaming Mode the default again.
- **Switch between desktop-first and gaming-first setups** without memorizing terminal commands.
- Avoid the legacy persistent-session helper that could force a specific desktop session and had more disruptive session behavior.

## What it does

The widget has two actions:

- **Desktop** → make Desktop Mode the default for future boots/logins.
- **Gaming** → make Gaming Mode the default for future boots/logins.

Version 2.0.3 first asks SteamOS what the current default is:

```bash
steamosctl get-default-login-mode
```

If the requested mode is already the default, the widget **does nothing** and reports that no change was needed. If it needs to change the setting, it uses Valve's current configuration command:

```bash
steamosctl set-default-login-mode desktop
steamosctl set-default-login-mode game
```

After a change, the widget queries SteamOS again and verifies the reported default when that query is available.

The widget **never calls** SteamOS's live session-switch commands (`switch-to-desktop-mode`, `switch-to-game-mode`, or `switch-to-login-mode`). It also does not contain a reboot command or an SDDM/Plasma restart command.

> [!NOTE]
> SteamOS still owns the implementation of `set-default-login-mode`. If a specific SteamOS build visibly redraws or restarts part of the desktop when that configuration command is run, that side effect is inside SteamOS rather than a live-switch request from this widget. See the refresh diagnostic below.

## Features

- Desktop and Gaming default-boot buttons.
- Reads and displays the current default boot mode when SteamOS supports the query.
- Marks the currently selected default in the button label.
- Does not re-run the setter when the selected mode is already the default.
- Verifies the setting after a successful change when SteamOS supports the query.
- Uses current `steamosctl` instead of legacy `steamos-session-select`.
- Never invokes SteamOS live session-switch commands.
- Desktop-session neutral: SteamOS remains in control of X11 vs Wayland.
- Detects whether `steamosctl` is available before enabling actions.
- Clear ready, working, verified-success, fallback-success, and error status messages.
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
Widget reads current default
        ↓
Already Desktop? ── yes ──> No write is performed
        │
        no
        ↓
Click Desktop
        ↓
steamosctl set-default-login-mode desktop
        ↓
Widget reads the setting back for verification
        ↓
Reboot/login later → SteamOS uses Desktop Mode as the default
```

Gaming works the same way with `game` as the requested default.

## What it intentionally does not do

This widget does not directly:

- invoke a live Desktop/Gaming session switch;
- automatically reboot;
- restart SDDM or Plasma;
- force Plasma X11 or Plasma Wayland;
- modify arbitrary system files;
- run user-entered shell commands;
- require root access.

It is intentionally a small GUI for SteamOS's default boot/login-mode configuration.

## Compatibility

| Environment | Status |
| --- | --- |
| Current SteamOS with `steamosctl` / Plasma 6 | Supported target |
| Steam Deck LCD / OLED on current SteamOS | Supported target |
| Other current SteamOS hardware | API-compatible target |
| SteamOS releases without `steamosctl` | Not supported by v2 |
| Non-SteamOS Plasma systems | Not supported unless they provide compatible `steamosctl` behavior |

## Troubleshooting

### Widget says `Cannot assign to non-existent property preferredRepresentation`

That was a Plasma 6 API bug in versions through 2.0.2. KDE moved `preferredRepresentation` onto the root `PlasmoidItem`; 2.0.3 removes the unnecessary assignment entirely.

Update with the recommended installer command above.

### Desktop visibly refreshes when changing the default

Version 2.0.3 avoids unnecessary writes by reading `get-default-login-mode` first. It also never calls a `switch-to-*` command.

To determine whether a remaining refresh comes from SteamOS itself, run this directly in Konsole:

```bash
steamosctl get-default-login-mode
```

If it is not already `desktop`, run:

```bash
steamosctl set-default-login-mode desktop
```

If **that direct SteamOS command** causes the same desktop refresh, the side effect is in the current SteamOS/`steamos-manager` implementation. Please include your SteamOS version when filing an issue so it can be tracked against that build.

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

GitHub Actions validate package metadata, archive structure, Plasma 6 API regressions, and the absence of legacy/live-switch commands on every change. Release automation publishes the installable `.plasmoid` plus its SHA-256 checksum whenever the widget version is bumped on `main`.

See [docs/KDE_STORE.md](docs/KDE_STORE.md) for KDE Store publication notes.

## License

MIT
