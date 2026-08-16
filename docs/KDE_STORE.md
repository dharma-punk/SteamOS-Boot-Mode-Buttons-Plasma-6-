# KDE Store publication

SteamOS Boot Mode Buttons v2 is intentionally a pure-QML Plasma 6 package so it can be distributed through Plasma's **Get New Widgets** / KDE Store flow without requiring users to compile anything.

## Suggested listing

**Name:** SteamOS Boot Mode Buttons

**Summary:** Choose whether SteamOS boots into Desktop Mode or Gaming Mode from a simple Plasma 6 widget.

**Description:**

SteamOS Boot Mode Buttons adds two focused actions to KDE Plasma: set Desktop Mode as the default boot target, or set Gaming Mode as the default boot target. Version 2.0 uses SteamOS's current `steamosctl` management interface and targets SteamOS 3.8+.

The widget changes only the default boot/login mode. It does not immediately switch sessions, restart SDDM, reboot the device, or force X11/Wayland. Desktop session selection remains under SteamOS control.

**Requirements:**

- SteamOS 3.8 or newer
- KDE Plasma 6
- `steamosctl`

**Version:** 2.0.0

**License:** MIT

**Category:** System Information

**Source / bug tracker:** use this GitHub repository and its Issues page.

## Upload asset

Use the exact `SteamOS-Boot-Mode-Buttons.zip` produced by `bash scripts/package.sh` or attached to the GitHub v2.0.0 release. Do not upload GitHub's automatically generated "Source code (zip)" archive.

The installable ZIP must have this structure at its root:

```text
metadata.json
contents/
  ui/
    main.qml
```

## Screenshots to capture on SteamOS

1. Desktop widget showing both **Desktop** and **Gaming** buttons.
2. Success state after selecting Desktop Mode.
3. Optional panel placement showing the compact/adaptive layout.

## Publication checklist

- [ ] Install the release ZIP on a current SteamOS 3.8+ device.
- [ ] Verify Desktop changes the next boot target without refreshing/restarting the current desktop.
- [ ] Verify Gaming changes the next boot target without switching the current session.
- [ ] Reboot once after each choice and confirm the selected mode starts.
- [ ] Capture current screenshots.
- [ ] Upload the release ZIP to the KDE Store / OpenDesktop Plasma widget category.
- [ ] Add the GitHub repository as the source URL and Issues as the bug tracker.
- [ ] Confirm installation works through Plasma's **Get New Widgets** UI.
