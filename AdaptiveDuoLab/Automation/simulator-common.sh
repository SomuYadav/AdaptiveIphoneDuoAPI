#!/bin/bash
# Shared by run-demo.sh and run-tests.sh. Uses the selected Xcode/DEVELOPER_DIR.

prepare_project() {
  if [[ "${REGENERATE_PROJECT:-0}" == "1" ]]; then
    if ! command -v tuist >/dev/null 2>&1; then
      echo "Tuist is not on PATH. Install it, or use the included Xcode project without REGENERATE_PROJECT=1." >&2
      return 1
    fi
    tuist generate --no-open
  fi
  if [[ ! -f AdaptiveDuoLab.xcodeproj/project.pbxproj ]]; then
    echo "The Xcode project is missing. Run tuist generate --no-open first." >&2
    return 1
  fi
}

prepare_build_settings() {
  # Keep the ordinary build free of unknown 27.1 symbols. A runtime availability
  # check cannot make a symbol available to an older SDK's compiler.
  ADAPTIVE_BUILD_SETTINGS=("CODE_SIGNING_ALLOWED=NO")
  local adaptive_sdk_version
  adaptive_sdk_version="$(xcrun --sdk iphonesimulator --show-sdk-version)"
  python3 -c '
import re, sys
version = tuple(int(part) for part in re.findall(r"\d+", sys.argv[1])[:2])
minimum = (27, 1) if sys.argv[2] == "1" else (26, 0)
version = (version + (0, 0))[:2]
if version < minimum:
    sys.exit("Selected iOS Simulator SDK " + sys.argv[1] + " is too old. Select Xcode with iOS " + ".".join(map(str, minimum)) + " SDK or later using DEVELOPER_DIR or xcode-select.")
' "$adaptive_sdk_version" "${DUO_SDK:-0}"
  if [[ "${DUO_SDK:-0}" == "1" ]]; then
    ADAPTIVE_BUILD_SETTINGS+=('SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) DUO_SDK')
  fi
}

resolve_simulator() {
  if ! command -v xcrun >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    echo "Run this script on a Mac with Xcode selected and python3 on PATH." >&2
    return 1
  fi
  xcrun simctl list devices available --json | python3 -c '
import json, re, sys
requested_id, requested_name = sys.argv[1:]
candidates = []
for runtime, devices in json.load(sys.stdin)["devices"].items():
    if ".iOS-" not in runtime:
        continue
    version = tuple(int(part) for part in re.findall(r"\d+", runtime.rsplit("iOS-", 1)[-1]))
    for device in devices:
        matches = (device["udid"] == requested_id) if requested_id else (device["name"] == requested_name)
        if matches and device.get("isAvailable", True):
            candidates.append((device.get("state") == "Booted", version, device["udid"]))
if not candidates:
    sys.exit("No available iOS simulator matches " + (requested_id or requested_name) + ". Set DEVICE_ID or DEVICE_NAME to an installed simulator.")
# Prefer an already booted match; otherwise use the newest installed iOS runtime.
print(max(candidates)[2])
' "${DEVICE_ID:-}" "${DEVICE_NAME:-iPhone 17 Pro}"
}
