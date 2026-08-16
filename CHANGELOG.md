# Changelog

## 2.0.0

- Migrated boot-mode control from the legacy `steamos-session-select` helper to `steamosctl set-default-login-mode`.
- Removed the X11-specific persistent Desktop Mode behavior; Desktop boot now follows SteamOS's configured desktop session.
- Kept boot selection non-disruptive by avoiding live session switching, SDDM restarts, and automatic reboots.
- Simplified the widget to focused Desktop and Gaming boot actions with clear status feedback.
- Modernized Plasma 6 QML imports and metadata.
- Added capability detection for `steamosctl` and explicit SteamOS 3.8+ compatibility messaging.
- Added panel-aware layout behavior and accessibility descriptions.
- Added package validation, reproducible ZIP packaging, CI artifacts, and automatic GitHub Releases.
- Added KDE Store publication guidance.
