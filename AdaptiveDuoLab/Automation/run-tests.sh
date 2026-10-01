#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="${DERIVED_DATA:-${TMPDIR:-/tmp}/AdaptiveDuoLab-Tests}"
RESULT_BUNDLE_PATH="${RESULT_BUNDLE_PATH:-$DERIVED_DATA/TestResults-$(date +%Y%m%d-%H%M%S).xcresult}"

cd "$ROOT"
source "$ROOT/Automation/simulator-common.sh"
prepare_project
DEVICE_ID="$(resolve_simulator)"
prepare_build_settings
echo "Testing on iOS simulator $DEVICE_ID"
xcodebuild test \
  -workspace AdaptiveDuoLab.xcworkspace \
  -scheme AdaptiveDuoLab \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_BUNDLE_PATH" \
  "${ADAPTIVE_BUILD_SETTINGS[@]}"
