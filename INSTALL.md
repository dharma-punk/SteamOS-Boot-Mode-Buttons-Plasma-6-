# Install SteamOS Boot Mode Buttons

## Recommended: one-command installer

Open **Konsole** in SteamOS Desktop Mode and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-/main/install.sh | bash
```

This is the most reliable installation method because it does not depend on your browser's downloaded filename. The installer downloads the latest release to a temporary `.plasmoid` file, validates the package structure, removes an older installed copy if present, and installs the latest version with `kpackagetool6`.

No `sudo` is used.

## GUI install

On the repository front page, use the **Download latest widget** link in the README. It points directly to the release asset named:

```text
SteamOS-Boot-Mode-Buttons.plasmoid
```

Then:

1. Right-click the desktop or panel and choose **Add Widgets**.
2. Open **Get New Widgets** → **Install from File…**.
3. Select `SteamOS-Boot-Mode-Buttons.plasmoid`.
4. Add **SteamOS Boot Mode Buttons** from the widget picker.

### Important: do not use GitHub's Code → Download ZIP

GitHub's green **Code → Download ZIP** button downloads the entire source repository. That ZIP is for developers and is **not** the Plasma widget package, so Plasma can report that it is not a valid package.

## If you already downloaded a file and are not sure what it is called

Run:

```bash
ls -lh ~/Downloads | grep -i 'SteamOS-Boot-Mode-Buttons'
```

This shows the exact filename your browser saved. Do not type a guessed filename into `kpackagetool6`.

## Manual terminal install

If you downloaded the actual `.plasmoid` release asset:

```bash
kpackagetool6 --type Plasma/Applet --install ~/Downloads/SteamOS-Boot-Mode-Buttons.plasmoid
```

If a previous version is already installed, the recommended installer above handles removal and reinstall automatically.

## What the installer changes

The installer only installs a user-level Plasma widget under your account. The widget itself calls these SteamOS commands when you press its buttons:

```bash
steamosctl set-default-login-mode desktop
steamosctl set-default-login-mode game
```

It does not use `sudo`, restart SDDM, force X11/Wayland, reboot the device, or immediately switch the current session.
