#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_DIR="${REPO_ROOT}/io.github.dharma_punk.steamos_boot_buttons"
METADATA="${PACKAGE_DIR}/metadata.json"
MAIN_QML="${PACKAGE_DIR}/contents/ui/main.qml"

test -f "${METADATA}"
test -f "${MAIN_QML}"
python3 -m json.tool "${METADATA}" >/dev/null

if grep -Eq 'X-Plasma-API"|import .+ [0-9]+\.[0-9]+' "${METADATA}" "${MAIN_QML}"; then
  echo "Found an obsolete Plasma API key or versioned QML import." >&2
  exit 1
fi

if command -v qmllint >/dev/null 2>&1; then
  qmllint "${MAIN_QML}"
else
  echo "qmllint not installed; skipped QML module validation."
fi

echo "SteamOS widget package checks passed."
