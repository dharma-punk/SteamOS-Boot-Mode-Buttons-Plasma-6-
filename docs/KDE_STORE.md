# KDE Store publication

SteamOS Boot Mode Buttons v2 is intentionally a pure-QML Plasma 6 package so it can be distributed through Plasma's **Get New Widgets** / KDE Store flow without requiring users to compile anything.

## Suggested listing

**Name:** SteamOS Boot Mode Buttons

**Summary:** Choose whether SteamOS boots into Desktop Mode or Gaming Mode from a simple Plasma 6 widget.

**Description:**

SteamOS Boot Mode Buttons adds two focused actions to KDE Plasma: set Desktop Mode as the default boot target, or set Gaming Mode as the default boot target. Version 2.0.4 uses SteamOS's current `steamosctl` management interface, displays the reported default, avoids unnecessary writes, and verifies successful changes when the installed SteamOS build supports the query.

The widget changes only the default boot/login mode. It does not immediately switch sessions, restart SDDM, reboot the device, or force X11/Wayland. Desktop session selection remains under SteamOS control.

**Requirements:**

- A current SteamOS release with `steamosctl`
- KDE Plasma 6
- `steamosctl`

**Version:** 2.0.4

**License:** MIT

**Category:** System Information

**Source / bug tracker:** use this GitHub repository and its Issues page.

## Upload asset

Use the exact `SteamOS-Boot-Mode-Buttons.plasmoid` produced by `bash scripts/package.sh` or attached to the latest GitHub release. Do not upload GitHub's automatically generated source archives.

A `.plasmoid` is a ZIP-formatted Plasma KPackage. The archive must have this structure at its root:

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

- [ ] Install the release `.plasmoid` on a current SteamOS device using **Add Widgets → Get New Widgets → Install from File…**.
- [ ] Verify Desktop changes the next boot target while the current desktop session remains open.
- [ ] Verify Gaming changes the next boot target without switching the current session.
- [ ] Verify pressing the already-selected mode performs no configuration write.
- [ ] Verify the selected mode is marked in the widget after the setting is read back.
- [ ] Reboot once after each choice and confirm the selected mode starts.
- [ ] Capture current screenshots.
- [ ] Upload the release `.plasmoid` to the KDE Store / OpenDesktop Plasma widget category.
- [ ] Add the GitHub repository as the source URL and Issues as the bug tracker.
- [ ] Confirm installation works through Plasma's **Get New Widgets** UI.
