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
ARCHIVE="${OUT_DIR}/SteamOS-Boot-Mode-Buttons.plasmoid"
CHECKSUM="${ARCHIVE}.sha256"

rm -f "${ARCHIVE}" "${CHECKSUM}"

# A .plasmoid file is a ZIP-formatted KPackage. Plasma's local widget
# installer expects the plasmoid extension even though the archive format is ZIP.
(
  cd "${PACKAGE_DIR}"
  zip -q -r "${ARCHIVE}" metadata.json contents
)

[[ "${ARCHIVE}" == *.plasmoid ]]
unzip -tqq "${ARCHIVE}"
unzip -Z1 "${ARCHIVE}" | grep -qx 'metadata.json'
unzip -Z1 "${ARCHIVE}" | grep -qx 'contents/ui/main.qml'

python3 - "${ARCHIVE}" <<'PY'
import json
import sys
import zipfile

archive = sys.argv[1]
with zipfile.ZipFile(archive) as zf:
    names = set(zf.namelist())
    required = {"metadata.json", "contents/ui/main.qml"}
    missing = required - names
    if missing:
        raise SystemExit(f"Missing required package entries: {sorted(missing)}")
    metadata = json.loads(zf.read("metadata.json"))
    if metadata.get("KPackageStructure") != "Plasma/Applet":
        raise SystemExit("metadata.json must declare KPackageStructure=Plasma/Applet")
    if metadata.get("X-Plasma-API-Minimum-Version") != "6.0":
        raise SystemExit("metadata.json must declare Plasma 6 minimum API")
PY

sha256sum "${ARCHIVE}" > "${CHECKSUM}"

echo "Built SteamOS Boot Mode Buttons ${VERSION}:"
echo "  ${ARCHIVE}"
echo "  ${CHECKSUM}"
