# SteamOS Boot Mode Buttons

A small KDE Plasma 6 widget that lets you choose whether SteamOS boots into **Desktop Mode** or **Gaming Mode**.

Version 2.0 uses SteamOS's current `steamosctl` interface and is designed for SteamOS 3.8+.

## What changed in 2.0

- Uses `steamosctl set-default-login-mode desktop` and `steamosctl set-default-login-mode game`.
- Changes only the default boot/login mode; it does **not** switch the current session, restart SDDM, or force an immediate reboot.
- Desktop Mode is session-neutral. The widget does not force X11 or Wayland; SteamOS keeps control of the user's configured desktop session.
- Uses current Plasma 6 metadata and unversioned QML imports.
- Keeps the applet focused on two safe actions instead of arbitrary shell commands, reboot controls, or profile presets.
- Adapts its layout for desktop and panel placement.
- GitHub Actions validate every change and automatically publish a ready-to-install release ZIP whenever the version is bumped on `main`.

Valve moved SteamOS desktop-session management toward `steamos-manager` in SteamOS 3.8, and Desktop Mode now defaults to Wayland. This widget intentionally follows that newer abstraction instead of managing SDDM sessions itself.

## Install — easiest method

1. Open the repository's **Releases** page.
2. Download **`SteamOS-Boot-Mode-Buttons.zip`** from the latest release.
3. In Desktop Mode, right-click the desktop or panel and choose **Add Widgets**.
4. Open **Get New Widgets** → **Install from File…**.
5. Select the downloaded ZIP.
6. Add **SteamOS Boot Mode Buttons** to your desktop or panel.

No terminal commands are required for normal installation.

### Terminal install

You can also install the release ZIP with:

```bash
kpackagetool6 --type Plasma/Applet --install ~/Downloads/SteamOS-Boot-Mode-Buttons.zip
```

To update an existing install:

```bash
kpackagetool6 --type Plasma/Applet --upgrade ~/Downloads/SteamOS-Boot-Mode-Buttons.zip
```

To remove it:

```bash
kpackagetool6 --type Plasma/Applet --remove io.github.dharma_punk.steamos_boot_buttons
```

## How it works

The two buttons run only these SteamOS commands:

```bash
steamosctl set-default-login-mode desktop
steamosctl set-default-login-mode game
```

The choice takes effect after reboot/login. The widget deliberately does not call the live session-switching commands, so clicking a boot-mode button should not tear down the desktop you are currently using.

The applet checks for `steamosctl` at startup. If it is unavailable, the buttons remain disabled and the widget explains that SteamOS 3.8+ is required.

## Compatibility

| Environment | v2 status |
| --- | --- |
| SteamOS 3.8+ / Plasma 6 | Supported target |
| Steam Deck LCD / OLED on current SteamOS | Supported target; device testing recommended |
| Steam Machine / other current SteamOS hardware | API-compatible target; device testing recommended |
| SteamOS 3.7 and older | Not supported by v2; uses the legacy session helper |
| Non-SteamOS Plasma systems | Not supported unless they intentionally provide compatible `steamosctl` behavior |

## Development

Validate the package:

```bash
bash scripts/validate.sh
```

Build the same installable ZIP produced by GitHub Actions:

```bash
bash scripts/package.sh
```

The archive is intentionally built with `metadata.json` and `contents/` at its root, matching KDE's Plasma widget package format.

## Releases

The `release.yml` workflow runs on pushes to `main`. It reads the version from `metadata.json`; if a matching `vX.Y.Z` tag does not already exist, it validates the widget, builds the ZIP, creates the tag/release, and uploads the ZIP plus its SHA-256 checksum.

For future releases, bump `KPlugin.Version` in `metadata.json` before merging to `main`.

## KDE Store

The v2 package remains pure QML and requires no compiled plugin, keeping it compatible with KDE Store distribution. See [`docs/KDE_STORE.md`](docs/KDE_STORE.md) for a ready-to-use listing and publication checklist.

## License

MIT
