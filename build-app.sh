#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
app_path="$PWD/build/Dreame Hub Swift.app"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp .build/release/DreameHub "$app_path/Contents/MacOS/DreameHub"
cp -R .build/release/DreameHub_DreameHub.bundle "$app_path/Contents/Resources/"
# Public-source build intentionally uses the macOS default app icon.
# No Dreame trademark artwork or opaque codec binary is bundled.
cp Info.plist "$app_path/Contents/Info.plist"
codesign --force --sign - "$app_path"
codesign --verify --deep --strict "$app_path"
echo "$app_path"
