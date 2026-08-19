# Changelog

## 2.0.4

- Prevented the initial default-mode query from overlapping with a button action, eliminating a race that could verify a change against stale query output.
- Simplified the asynchronous state tracking to one requested-mode value instead of separate pending and verification values.
- Mode detection now reads only successful standard output and matches complete `desktop` or `game` values instead of loose substrings.
- Command failures now prefer the more useful standard-error message when SteamOS also writes to standard output.
- Updated GitHub Actions checkout steps to the current supported major and removed an unnecessary full-history fetch from releases.
- Updated the KDE Store publication notes and checklist to match the current widget release and behavior.

## 2.0.3

- Fixed the Plasma 6 runtime error caused by assigning `preferredRepresentation` through the attached `Plasmoid` object; the unnecessary assignment is now removed.
- Added `steamosctl get-default-login-mode` support so the widget can read the current default boot mode.
- Avoids running `set-default-login-mode` when the requested mode is already selected, preventing unnecessary SteamOS configuration writes.
- Re-queries the default mode after a successful change and verifies the result when the current SteamOS build supports the getter.
- Added CI regression checks that reject legacy `steamos-session-select`, live `switch-to-*` session commands, forced desktop-session selection, and the invalid Plasma 6 `Plasmoid.preferredRepresentation` pattern.
- Clarified refresh diagnostics: the widget never requests a live session switch, reboot, SDDM restart, or Plasma restart; any refresh caused by a direct `set-default-login-mode` command is a SteamOS/`steamos-manager` side effect to track against that SteamOS build.

## 2.0.2

- Added a filename-independent one-command installer for SteamOS Desktop Mode.
- The installer downloads the latest release directly, validates the package archive and plugin ID, and updates or cleanly reinstalls the widget as needed.
- Added CI coverage for installer syntax and the live `releases/latest` download path.
- Reworked the GitHub front page around real use cases, features, how the widget behaves, and two clear installation paths.
- Added an explicit warning that GitHub's green **Code → Download ZIP** source archive is not an installable Plasma widget.
- Added direct-download and troubleshooting guidance for filename/path errors and invalid source ZIPs.
- Release automation now includes `install.sh` alongside the `.plasmoid` and checksum.

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
