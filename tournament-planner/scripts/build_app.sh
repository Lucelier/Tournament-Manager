#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"
APP_PATH="$DIST_DIR/TournamentPlanner.app"

if xcodebuild -version >/dev/null 2>&1; then
  xcodebuild \
    -project TournamentPlanner.xcodeproj \
    -scheme TournamentPlanner \
    -configuration Release \
    -derivedDataPath "$ROOT_DIR/build/DerivedData" \
    build

  rm -rf "$APP_PATH"
  cp -R "$ROOT_DIR/build/DerivedData/Build/Products/Release/TournamentPlanner.app" "$APP_PATH"
else
  echo "Vollständiges Xcode nicht gefunden; baue App-Bundle direkt mit swiftc."
  rm -rf "$APP_PATH"
  mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"

  xcrun swiftc -O -parse-as-library -target x86_64-apple-macosx14.0 \
    -o "$APP_PATH/Contents/MacOS/TournamentPlanner" \
    TournamentPlanner/TournamentPlannerApp.swift \
    TournamentPlanner/Model/Turnier.swift \
    TournamentPlanner/Model/PlanungsEngine.swift \
    TournamentPlanner/ViewModel/TurnierViewModel.swift \
    TournamentPlanner/Services/PersistenzService.swift \
    TournamentPlanner/Services/PlanExportFormatter.swift \
    TournamentPlanner/Services/XLSXExportService.swift \
    TournamentPlanner/Services/PDFExportService.swift \
    TournamentPlanner/Views/ContentView.swift \
    TournamentPlanner/Views/SetupView.swift \
    TournamentPlanner/Views/SpielplanView.swift \
    TournamentPlanner/Views/ExportView.swift \
    TournamentPlanner/Views/Components/GruppenListeView.swift \
    TournamentPlanner/Views/Components/SportartenListeView.swift \
    TournamentPlanner/Views/Components/ZeitslotListeView.swift \
    TournamentPlanner/Views/Components/PaarungsZelleView.swift

  cat > "$APP_PATH/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>de</string>
	<key>CFBundleExecutable</key>
	<string>TournamentPlanner</string>
	<key>CFBundleIdentifier</key>
	<string>ch.local.TournamentPlanner</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>TournamentPlanner</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
PLIST

  codesign --force --sign - "$APP_PATH" >/dev/null
fi

echo "Installierbare App erstellt: $APP_PATH"
