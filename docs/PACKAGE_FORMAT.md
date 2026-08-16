# Plasma package format

SteamOS Boot Mode Buttons is distributed as `SteamOS-Boot-Mode-Buttons.plasmoid`.

A `.plasmoid` file is a ZIP-formatted KDE KPackage intended for Plasma's local widget installer. Its archive root contains:

```text
metadata.json
contents/
  ui/
    main.qml
```

The package metadata declares:

```json
"KPackageStructure": "Plasma/Applet",
"X-Plasma-API-Minimum-Version": "6.0"
```

Do not publish the manual-install asset with a `.zip` filename. Plasma's **Install from File…** workflow identifies downloadable widget packages as plasmoid files even though the underlying archive format is ZIP.
