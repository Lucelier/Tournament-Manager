#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$DIST_DIR/TournamentPlanner.app"
DMG_PATH="$DIST_DIR/TournamentPlanner.dmg"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Fehler: $APP_PATH nicht gefunden. Zuerst scripts/build_app.sh ausführen." >&2
  exit 1
fi

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "1.0")"

# Staging-Ordner: App + Verknüpfung zu /Applications für das übliche Drag-&-Drop-Layout
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create \
  -volname "TournamentPlanner $VERSION" \
  -srcfolder "$STAGING_DIR" \
  -format UDZO \
  -ov \
  "$DMG_PATH"

echo "DMG erstellt: $DMG_PATH"
