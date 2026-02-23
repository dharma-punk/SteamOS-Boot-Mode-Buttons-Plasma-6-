#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_ID="io.github.dharma_punk.steamos_boot_buttons"
SOURCE_DIR="${REPO_ROOT}/${PACKAGE_ID}"
TARGET_ROOT="${HOME}/.local/share/plasma/plasmoids"
TARGET_DIR="${TARGET_ROOT}/${PACKAGE_ID}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Missing source directory: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_ROOT}"
rm -rf "${TARGET_DIR}"
cp -a "${SOURCE_DIR}" "${TARGET_ROOT}/"

echo "Installed ${PACKAGE_ID} to ${TARGET_DIR}"
echo "Restart plasmashell (or log out/in) to pick up changes:"
echo "  kquitapp6 plasmashell && kstart6 plasmashell"
