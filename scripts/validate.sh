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

python3 - "${METADATA}" <<'PY'
import json
import re
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

plugin = data.get("KPlugin", {})
checks = {
    "KPackageStructure": data.get("KPackageStructure") == "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": data.get("X-Plasma-API-Minimum-Version") == "6.0",
    "KPlugin.Id": plugin.get("Id") == "io.github.dharma_punk.steamos_boot_buttons",
    "KPlugin.Name": bool(plugin.get("Name")),
    "KPlugin.Version": bool(re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", str(plugin.get("Version", "")))),
}

failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit("Invalid Plasma package metadata: " + ", ".join(failed))
PY

VERSION="$(python3 - "${METADATA}" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle)["KPlugin"]["Version"])
PY
)"

if grep -Eq '"X-Plasma-API"|import .+ [0-9]+\.[0-9]+' "${METADATA}" "${MAIN_QML}"; then
  echo "Found an obsolete Plasma API key or versioned QML import." >&2
  exit 1
fi

if grep -Rq "steamos-session-select" "${PACKAGE_DIR}"; then
  echo "Legacy steamos-session-select usage is not allowed in v2." >&2
  exit 1
fi

grep -Fq 'steamosctl set-default-login-mode desktop' "${MAIN_QML}"
grep -Fq 'steamosctl set-default-login-mode game' "${MAIN_QML}"
grep -Fq 'command -v steamosctl' "${MAIN_QML}"

if grep -Rq "set-default-desktop-session" "${PACKAGE_DIR}"; then
  echo "The boot-mode widget must not force X11, Wayland, or another desktop session." >&2
  exit 1
fi

if command -v qmllint >/dev/null 2>&1; then
  qmllint "${MAIN_QML}"
else
  echo "qmllint not installed; skipped runtime QML module validation."
fi

echo "SteamOS Boot Mode Buttons ${VERSION} package checks passed."
