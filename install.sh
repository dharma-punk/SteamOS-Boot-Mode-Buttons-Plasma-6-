#!/usr/bin/env bash
set -euo pipefail

REPO="dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-"
PACKAGE_ID="io.github.dharma_punk.steamos_boot_buttons"
ASSET_NAME="SteamOS-Boot-Mode-Buttons.plasmoid"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ASSET_NAME}"

say() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

command -v kpackagetool6 >/dev/null 2>&1 || fail "kpackagetool6 was not found. This installer requires KDE Plasma 6."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
PACKAGE_FILE="${TMP_DIR}/${ASSET_NAME}"

say "SteamOS Boot Mode Buttons installer"
say "Downloading the latest release…"

if command -v curl >/dev/null 2>&1; then
  curl --fail --location --retry 3 --silent --show-error \
    --output "${PACKAGE_FILE}" "${DOWNLOAD_URL}"
elif command -v wget >/dev/null 2>&1; then
  wget -q --tries=3 --output-document="${PACKAGE_FILE}" "${DOWNLOAD_URL}"
else
  fail "Neither curl nor wget is available to download the release."
fi

[[ -s "${PACKAGE_FILE}" ]] || fail "The downloaded package is empty."

if command -v unzip >/dev/null 2>&1; then
  unzip -tq "${PACKAGE_FILE}" >/dev/null || fail "The downloaded release is not a readable package archive."
  unzip -Z1 "${PACKAGE_FILE}" | grep -qx 'metadata.json' || fail "metadata.json is missing from the package root."
  unzip -Z1 "${PACKAGE_FILE}" | grep -qx 'contents/ui/main.qml' || fail "contents/ui/main.qml is missing from the package."
fi

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -Fq "${PACKAGE_ID}"; then
  say "Removing the currently installed copy…"
  kpackagetool6 --type Plasma/Applet --remove "${PACKAGE_ID}" >/dev/null
fi

say "Installing the latest widget…"
kpackagetool6 --type Plasma/Applet --install "${PACKAGE_FILE}"

say ""
say "Installed successfully."
say "Open Add Widgets and add ‘SteamOS Boot Mode Buttons’ to your desktop or panel."
say "The widget changes the default mode for future boots; it does not switch your current session."
