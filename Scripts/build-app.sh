#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"

if pgrep -x Banish >/dev/null 2>&1 || pgrep -x Cliner >/dev/null 2>&1; then
  osascript -e 'tell application "Banish" to quit' >/dev/null 2>&1 || osascript -e 'tell application "Cliner" to quit' >/dev/null 2>&1 || true
  sleep 0.4
fi

# Desktop is an iCloud folder, so Finder metadata lands on .build and codesign
# rejects it. Compile outside that folder.
SCRATCH="${TMPDIR%/}/app-cliner-build"
mkdir -p "$SCRATCH"
swift test --scratch-path "$SCRATCH"
swift build -c release --scratch-path "$SCRATCH"

APP="$ROOT/build/Banish.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$SCRATCH/out/Products/Release/Cliner" "$APP/Contents/MacOS/Banish"
chmod +x "$APP/Contents/MacOS/Banish"
cp "$ROOT/Support/Info.plist" "$APP/Contents/Info.plist"

ICONSET="$ROOT/build/AppIcon.iconset"
if swift "$ROOT/Scripts/make-icon.swift" "$ICONSET"; then
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
fi

signed=0
for _ in 1 2 3 4 5 6 7 8; do
  xattr -cr "$APP" >/dev/null 2>&1 || true
  if codesign --force --sign - "$APP"; then
    signed=1
    break
  fi
  sleep 0.15
done
if [[ "$signed" -ne 1 ]]; then
  echo "codesign failed" >&2
  exit 1
fi
echo "Built $APP"
