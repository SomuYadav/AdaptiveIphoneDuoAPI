#!/usr/bin/env bash
set -euo pipefail

# Enable the native API examples using the selected Xcode 27.1 SDK.
# simulator-common.sh checks that the matching SDK/runtime are available.
ADAPTIVE_API_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DUO_SDK=1
exec "$ADAPTIVE_API_SCRIPT_DIR/run-demo.sh" -demo-tab Settings "$@"
