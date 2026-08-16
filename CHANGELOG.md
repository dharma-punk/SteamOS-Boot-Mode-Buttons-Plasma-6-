# Changelog

## 2.0.1

- Fixed manual installation through Plasma's **Install from File…** flow by publishing the installable archive with the correct `.plasmoid` extension instead of `.zip`.
- Kept the package internally ZIP-formatted with `metadata.json` and `contents/` at the archive root.
- Added CI checks for the `.plasmoid` archive, required package files, `KPackageStructure`, Plasma 6 minimum API, plugin ID, and semantic version.
- Updated release automation and installation documentation to use `SteamOS-Boot-Mode-Buttons.plasmoid`.

## 2.0.0

- Migrated boot-mode control from the legacy `steamos-session-select` helper to `steamosctl set-default-login-mode`.
- Removed the X11-specific persistent Desktop Mode behavior; Desktop boot now follows SteamOS's configured desktop session.
- Kept boot selection non-disruptive by avoiding live session switching, SDDM restarts, and automatic reboots.
- Simplified the widget to focused Desktop and Gaming boot actions with clear status feedback.
- Modernized Plasma 6 QML imports and metadata.
- Added capability detection for `steamosctl` and explicit SteamOS 3.8+ compatibility messaging.
- Added panel-aware layout behavior and accessibility descriptions.
- Added package validation, reproducible release packaging, CI artifacts, and automatic GitHub Releases.
- Added KDE Store publication guidance.
