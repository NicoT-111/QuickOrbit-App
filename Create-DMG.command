#!/bin/zsh
set -euo pipefail

release_root="${0:A:h}"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$release_root/Packaging/Info.plist")"
archive="$release_root/QuickOrbit-v${version}.zip"
background="$release_root/Resources/DMG-background.png"
output="$release_root/QuickOrbit-v${version}.dmg"
work_root="$(/usr/bin/mktemp -d "${TMPDIR:-/private/tmp}/quickorbit-dmg.XXXXXX")"
staging="$work_root/staging"
mountpoint="$work_root/mount"
rw_image="$work_root/QuickOrbit-rw.dmg"
mounted="false"

cleanup() {
    if [[ "$mounted" == "true" ]]; then
        /usr/bin/hdiutil detach "$mountpoint" -quiet || true
    fi
    /bin/rm -rf "$work_root"
}
trap cleanup EXIT

[[ -f "$archive" ]] || { print -u2 "Release-ZIP fehlt: $archive"; exit 1; }
[[ -f "$background" ]] || { print -u2 "DMG-Hintergrund fehlt: $background"; exit 1; }

/bin/mkdir -p "$staging/.background" "$mountpoint"
/usr/bin/ditto -x -k "$archive" "$staging"
/usr/bin/codesign --verify --deep --strict "$staging/QuickOrbit.app"
/usr/bin/ditto "$background" "$staging/.background/DMG-background.png"
/bin/ln -s /Applications "$staging/Applications"

# Build a writable image first so Finder can persist its custom icon layout.
/usr/bin/hdiutil create -volname "QuickOrbit" -srcfolder "$staging" \
    -ov -format UDRW "$rw_image"
/usr/bin/hdiutil attach -nobrowse -noautoopen -readwrite \
    -mountpoint "$mountpoint" "$rw_image"
mounted="true"

/usr/bin/osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "QuickOrbit"
        open
        set theWindow to container window
        set current view of theWindow to icon view
        set toolbar visible of theWindow to false
        set statusbar visible of theWindow to false
        set bounds of theWindow to {120, 100, 1080, 740}
        set viewOptions to icon view options of theWindow
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set text size of viewOptions to 14
        set background picture of viewOptions to file ".background:DMG-background.png"
        set position of item "QuickOrbit.app" of theWindow to {250, 330}
        set position of item "Applications" of theWindow to {710, 330}
    end tell
    update disk "QuickOrbit"
end tell
APPLESCRIPT

/bin/sleep 2
/usr/bin/osascript -e 'tell application "Finder" to close every window whose name is "QuickOrbit"' || true
/usr/bin/sync
/usr/bin/hdiutil detach "$mountpoint"
mounted="false"

/usr/bin/hdiutil convert "$rw_image" -quiet -ov -format UDZO -imagekey zlib-level=9 -o "$output"
/usr/bin/hdiutil verify "$output"

print "Fertig: $output"
