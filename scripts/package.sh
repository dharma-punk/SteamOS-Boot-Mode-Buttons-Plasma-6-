#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_DIR="${REPO_ROOT}/io.github.dharma_punk.steamos_boot_buttons"
METADATA="${PACKAGE_DIR}/metadata.json"
OUT_DIR="${1:-${REPO_ROOT}/dist}"

VERSION="$(python3 - "${METADATA}" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle)["KPlugin"]["Version"])
PY
)"

mkdir -p "${OUT_DIR}"
OUT_DIR="$(cd "${OUT_DIR}" && pwd)"
ARCHIVE="${OUT_DIR}/SteamOS-Boot-Mode-Buttons.zip"
CHECKSUM="${ARCHIVE}.sha256"

rm -f "${ARCHIVE}" "${CHECKSUM}"
(
  cd "${PACKAGE_DIR}"
  zip -q -r "${ARCHIVE}" metadata.json contents
)

unzip -Z1 "${ARCHIVE}" | grep -qx 'metadata.json'
unzip -Z1 "${ARCHIVE}" | grep -qx 'contents/ui/main.qml'
sha256sum "${ARCHIVE}" > "${CHECKSUM}"

echo "Built SteamOS Boot Mode Buttons ${VERSION}:"
echo "  ${ARCHIVE}"
echo "  ${CHECKSUM}"
