#!/usr/bin/env bash
set -euo pipefail

REPO="dharma-punk/SteamOS-Boot-Mode-Buttons-Plasma-6-"
PACKAGE_ID="io.github.dharma_punk.steamos_boot_buttons"
ASSET_NAME="SteamOS-Boot-Mode-Buttons.plasmoid"
DOWNLOAD_URL="${STEAMOS_BOOT_BUTTONS_DOWNLOAD_URL:-https://github.com/${REPO}/releases/latest/download/${ASSET_NAME}}"
DRY_RUN="${STEAMOS_BOOT_BUTTONS_DRY_RUN:-0}"

say() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

if [[ "${DRY_RUN}" != "1" ]]; then
  command -v kpackagetool6 >/dev/null 2>&1 || fail "kpackagetool6 was not found. This installer requires KDE Plasma 6."
fi

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
  unzip -p "${PACKAGE_FILE}" metadata.json | grep -Fq '"KPackageStructure": "Plasma/Applet"' || fail "The package is not marked as a Plasma/Applet."
  unzip -p "${PACKAGE_FILE}" metadata.json | grep -Fq "\"Id\": \"${PACKAGE_ID}\"" || fail "The downloaded package has an unexpected plugin ID."
fi

say "Package download and structure validation passed."

if [[ "${DRY_RUN}" == "1" ]]; then
  say "Dry run complete; installation was intentionally skipped."
  exit 0
fi

if ! command -v steamosctl >/dev/null 2>&1; then
  say "Warning: steamosctl was not found. The widget can install, but its boot-mode buttons require current SteamOS."
fi

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -Fq "${PACKAGE_ID}"; then
  say "An existing copy is installed. Trying an in-place update…"
  if ! kpackagetool6 --type Plasma/Applet --upgrade "${PACKAGE_FILE}"; then
    say "In-place update was not accepted; performing a clean reinstall…"
    kpackagetool6 --type Plasma/Applet --remove "${PACKAGE_ID}" >/dev/null
    kpackagetool6 --type Plasma/Applet --install "${PACKAGE_FILE}"
  fi
else
  say "Installing the widget…"
  kpackagetool6 --type Plasma/Applet --install "${PACKAGE_FILE}"
fi

say ""
say "Installed successfully."
say "Open Add Widgets and add ‘SteamOS Boot Mode Buttons’ to your desktop or panel."
say "The widget changes the default mode for future boots; it does not switch your current session."
