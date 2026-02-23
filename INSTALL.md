# Install Guide (GitHub + Terminal + GUI)

## 0) Fast local install (download folder, then copy)

If you already have the repository folder, you can skip ZIP packaging and copy directly:

```bash
mkdir -p ~/.local/share/plasma/plasmoids
cp -a io.github.dharma_punk.steamos_boot_buttons ~/.local/share/plasma/plasmoids/
kquitapp6 plasmashell && kstart6 plasmashell
```

Equivalent helper script:

```bash
bash scripts/install-local.sh
```

### Update with only `main.qml` (advanced)

If you only want to update runtime logic, you can replace just the installed UI file:

```bash
cp -a io.github.dharma_punk.steamos_boot_buttons/contents/ui/main.qml \
  ~/.local/share/plasma/plasmoids/io.github.dharma_punk.steamos_boot_buttons/contents/ui/main.qml
kquitapp6 plasmashell && kstart6 plasmashell
```

This guide explains exactly how to install the widget from GitHub and why `kpackagetool6` may fail.

## 1) Download the correct ZIP from GitHub

Use **one** of these options:

- **Preferred:** Download a release asset named like:
  - `io.github.dharma_punk.steamos_boot_buttons.zip`
- **If building yourself from repo clone:** create the ZIP locally:

```bash
zip -r io.github.dharma_punk.steamos_boot_buttons.zip io.github.dharma_punk.steamos_boot_buttons
```

### Important

GitHub's default **Source code (zip)** download usually wraps the whole repository and is often **not directly installable** by `kpackagetool6` as a Plasma package.

A valid install ZIP must contain this top-level folder structure:

- `io.github.dharma_punk.steamos_boot_buttons/metadata.json`
- `io.github.dharma_punk.steamos_boot_buttons/contents/...`

## 2) Install from terminal

```bash
kpackagetool6 -t Plasma/Applet -i /full/path/to/io.github.dharma_punk.steamos_boot_buttons.zip
```

Example:

```bash
kpackagetool6 -t Plasma/Applet -i ~/Downloads/io.github.dharma_punk.steamos_boot_buttons.zip
```

## 3) Alternative GUI install

1. Right-click desktop or panel and open **Add Widgets**.
2. Choose **Get New Widgets** → **Install from File...**
3. Select `io.github.dharma_punk.steamos_boot_buttons.zip`.
4. Add **SteamOS Boot Mode Buttons** to panel or desktop.

## 4) Update / remove

Update:

```bash
kpackagetool6 -t Plasma/Applet -u /full/path/to/io.github.dharma_punk.steamos_boot_buttons.zip
```

Remove:

```bash
kpackagetool6 -t Plasma/Applet -r io.github.dharma_punk.steamos_boot_buttons
```

## 5) Verify installed package

```bash
kpackagetool6 -t Plasma/Applet --list | grep steamos_boot_buttons
```

If listed, installation succeeded.

## 6) Common failures and fixes

- **Error: package invalid / missing metadata**
  - You likely used GitHub "Source code (zip)".
  - Use the release asset ZIP or rebuild ZIP from `io.github.dharma_punk.steamos_boot_buttons/` only.

- **Error: `kpackagetool6: command not found`**
  - Install Plasma package tools for your distro.

- **Widget installs but actions fail**
  - `steamos-session-select` may be missing on non-SteamOS systems.
