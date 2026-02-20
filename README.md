# SteamOS Boot Mode Buttons (Plasma 6)

A KDE Plasma 6 widget (plasmoid) for quickly switching SteamOS default boot mode between Desktop and Gaming mode.

## Features

- One-click actions for Desktop and Gaming boot targets.
- Optional confirmation before applying actions.
- Inline status feedback and optional passive notifications.
- Panel/Desktop adaptive layout behavior.
- Advanced options:
  - Preset profiles
  - Custom command overrides
  - Optional reboot action with configurable confirmation
- i18n-ready user-facing strings and accessibility labels.

## Requirements

- KDE Plasma 6
- `kpackagetool6`
- SteamOS command support (`steamos-session-select`)

## Install

### From ZIP

```bash
kpackagetool6 -t Plasma/Applet -i io.github.dharma_punk.steamos_boot_buttons.zip
```

### Update existing install

```bash
kpackagetool6 -t Plasma/Applet -u io.github.dharma_punk.steamos_boot_buttons.zip
```

### Remove

```bash
kpackagetool6 -t Plasma/Applet -r io.github.dharma_punk.steamos_boot_buttons
```

## Development

The widget source lives under:

- `io.github.dharma_punk.steamos_boot_buttons/`

Key files:

- `metadata.json` – package/plugin metadata
- `contents/ui/main.qml` – main widget UI + runtime behavior
- `contents/ui/configGeneral.qml` – settings page
- `contents/config/main.xml` – persisted settings schema

## Packaging for release

Create a distributable ZIP containing only the plasmoid directory:

```bash
zip -r io.github.dharma_punk.steamos_boot_buttons.zip io.github.dharma_punk.steamos_boot_buttons
```

## License

MIT.
