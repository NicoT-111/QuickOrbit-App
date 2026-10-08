#!/bin/zsh
set -euo pipefail

release_root="${0:A:h}"
source_file="$release_root/Source/QuickOrbit.swift"
app_bundle="$release_root/QuickOrbit.app"
build_dir="$release_root/../.build-QuickOrbit"
module_cache="$build_dir/ModuleCache"
asset_catalog="$release_root/Resources/Assets.xcassets"
asset_output="$build_dir/AssetOutput"
sparkle_root="$release_root/Vendor/Sparkle"
if [[ ! -d "$sparkle_root/Sparkle.framework" ]]; then
    /bin/zsh "$release_root/Fetch-Sparkle.command"
fi
release_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$release_root/Packaging/Info.plist")"
archive_name="QuickOrbit-v${release_version}.zip"
archive_path="$release_root/$archive_name"
staging_root="$(mktemp -d "${TMPDIR:-/private/tmp}/quickorbit-build.XXXXXX")"
staged_app_bundle="$staging_root/QuickOrbit.app"
trap '/bin/rm -rf "$staging_root"' EXIT

mkdir -p "$staged_app_bundle/Contents/MacOS" "$staged_app_bundle/Contents/Resources" "$staged_app_bundle/Contents/Frameworks" "$build_dir" "$module_cache" "$asset_output"

echo "QuickOrbit wird als Universal-App gebaut …"

xcrun swiftc -O -whole-module-optimization -warnings-as-errors -parse-as-library -disable-sandbox \
    -module-cache-path "$module_cache" \
    -target arm64-apple-macos14.0 \
    -F "$sparkle_root" -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    "$source_file" \
    -o "$build_dir/QuickOrbit-arm64"

xcrun swiftc -O -whole-module-optimization -warnings-as-errors -parse-as-library -disable-sandbox \
    -module-cache-path "$module_cache" \
    -target x86_64-apple-macos14.0 \
    -F "$sparkle_root" -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    "$source_file" \
    -o "$build_dir/QuickOrbit-x86_64"

lipo -create \
    "$build_dir/QuickOrbit-arm64" \
    "$build_dir/QuickOrbit-x86_64" \
    -output "$staged_app_bundle/Contents/MacOS/QuickOrbit"

cp "$release_root/Packaging/Info.plist" "$staged_app_bundle/Contents/Info.plist"
cp "$release_root/Packaging/PkgInfo" "$staged_app_bundle/Contents/PkgInfo"
/usr/bin/ditto --noextattr --noqtn "$sparkle_root/Sparkle.framework" "$staged_app_bundle/Contents/Frameworks/Sparkle.framework"
cp "$sparkle_root/LICENSE" "$staged_app_bundle/Contents/Resources/Sparkle-LICENSE.txt"
xcrun actool "$asset_catalog" \
    --compile "$asset_output" \
    --platform macosx \
    --minimum-deployment-target 14.0 \
    --app-icon AppIcon \
    --output-partial-info-plist "$asset_output/asset-info.plist" \
    --warnings \
    --notices
cp "$asset_output/AppIcon.icns" "$staged_app_bundle/Contents/Resources/AppIcon.icns"
cp "$asset_output/Assets.car" "$staged_app_bundle/Contents/Resources/Assets.car"
chmod 755 "$staged_app_bundle/Contents/MacOS/QuickOrbit"

signing_identity="${QUICKORBIT_SIGNING_IDENTITY:-${QUICKORBIT_APP_STORE_SIGNING_IDENTITY:-}}"

sign_bundle() {
    # Finder can reattach metadata while an app bundle is being rebuilt in a
    # visible folder. Remove it immediately before every signing attempt.
    /usr/bin/xattr -cr "$staged_app_bundle"
    /usr/bin/xattr -d com.apple.FinderInfo "$staged_app_bundle" 2>/dev/null || true
    /usr/bin/xattr -d com.apple.ResourceFork "$staged_app_bundle" 2>/dev/null || true

    if [[ -n "$signing_identity" ]]; then
        local framework="$staged_app_bundle/Contents/Frameworks/Sparkle.framework"
        # Sign nested helpers first. Host entitlements must not be copied to them.
        codesign --force --options runtime --timestamp --preserve-metadata=entitlements --sign "$signing_identity" "$framework/Versions/B/XPCServices/Downloader.xpc"
        codesign --force --options runtime --timestamp --preserve-metadata=entitlements --sign "$signing_identity" "$framework/Versions/B/XPCServices/Installer.xpc"
        codesign --force --options runtime --timestamp --sign "$signing_identity" "$framework/Versions/B/Autoupdate"
        codesign --force --options runtime --timestamp --sign "$signing_identity" "$framework/Versions/B/Updater.app"
        codesign --force --options runtime --timestamp --sign "$signing_identity" "$framework"
        codesign --force --options runtime --timestamp \
            --entitlements "$release_root/Packaging/QuickOrbit.entitlements" \
            --sign "$signing_identity" "$staged_app_bundle"
    else
        # Local test builds remain ad-hoc signed. Public GitHub releases should set
        # QUICKORBIT_SIGNING_IDENTITY to a Developer ID Application certificate.
        codesign --force --deep \
            --entitlements "$release_root/Packaging/QuickOrbit.entitlements" \
            --sign - "$staged_app_bundle"
    fi
}

if ! sign_bundle; then
    /bin/sleep 0.2
    sign_bundle
fi
codesign --verify --deep --strict --verbose=1 "$staged_app_bundle"

# For public distribution, notarize before archiving so the downloadable ZIP
# contains the stapled application. Credentials remain in the local Keychain.
if [[ -n "${QUICKORBIT_NOTARY_PROFILE:-}" ]]; then
    if [[ -z "$signing_identity" ]]; then
        echo "Notarisierung benötigt QUICKORBIT_SIGNING_IDENTITY." >&2
        exit 1
    fi
    /usr/bin/ditto -c -k --keepParent "$staged_app_bundle" "$staging_root/Notarize.zip"
    xcrun notarytool submit "$staging_root/Notarize.zip" --keychain-profile "$QUICKORBIT_NOTARY_PROFILE" --wait
    xcrun stapler staple "$staged_app_bundle"
    xcrun stapler validate "$staged_app_bundle"
fi

# Archive the clean staged bundle before placing the convenient Finder copy in
# the release folder. This prevents cloud/Finder metadata from entering the ZIP.
/bin/rm -f "$archive_path"
(cd "$staging_root" && /usr/bin/zip -qryX "$archive_path" "QuickOrbit.app")

# The ZIP is the distributable artifact. Verify a fresh extraction in the
# private staging directory so Finder/iCloud metadata can never mask its state.
archive_check="$staging_root/ArchiveCheck"
mkdir -p "$archive_check"
/usr/bin/unzip -q "$archive_path" -d "$archive_check"
codesign --verify --deep --strict --verbose=1 "$archive_check/QuickOrbit.app"

if [[ "$app_bundle" != "$release_root/QuickOrbit.app" ]]; then
    echo "Unerwartetes Ausgabeziel: $app_bundle" >&2
    exit 1
fi
/bin/rm -rf "$app_bundle"
/usr/bin/ditto --noextattr --noqtn "$staged_app_bundle" "$app_bundle"
if ! codesign --verify --deep --strict --verbose=1 "$app_bundle"; then
    echo "Hinweis: Finder hat Metadaten an die lose App-Kopie angehängt; die separat geprüfte Release-ZIP ist unverändert gültig." >&2
fi

echo "Fertig: $app_bundle"
echo "Weitergabe: $archive_path"
file "$app_bundle/Contents/MacOS/QuickOrbit"
