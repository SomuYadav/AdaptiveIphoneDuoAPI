#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="${DERIVED_DATA:-${TMPDIR:-/tmp}/AdaptiveDuoLab-Demo}"

cd "$ROOT"
source "$ROOT/Automation/simulator-common.sh"
prepare_project
DEVICE_ID="$(resolve_simulator)"
prepare_build_settings
echo "Building for iOS simulator $DEVICE_ID"
xcodebuild \
  -workspace AdaptiveDuoLab.xcworkspace \
  -scheme AdaptiveDuoLab \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  "${ADAPTIVE_BUILD_SETTINGS[@]}" \
  build

APP="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/AdaptiveDuoLab.app"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl install "$DEVICE_ID" "$APP"
xcrun simctl launch --terminate-running-process "$DEVICE_ID" com.example.AdaptiveDuoLab -reset-data "$@"
open -a Simulator
