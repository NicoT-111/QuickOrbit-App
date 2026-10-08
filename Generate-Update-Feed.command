#!/bin/zsh
set -euo pipefail
release_root="${0:A:h}"
repository="NicoT-111/QuickOrbit-App"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$release_root/Packaging/Info.plist")"
archive="$release_root/QuickOrbit-v${version}.zip"
notes="$release_root/GitHub-Release/ReleaseNotes-v${version}.md"
key="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$release_root/Packaging/Info.plist" 2>/dev/null || true)"
private_key="${QUICKORBIT_UPDATE_KEY_FILE:-$release_root/../../../../.quickorbit-signing/QuickOrbit-ed25519.key}"
if [[ -z "$key" ]]; then
    echo "Zuerst Setup-Updates.command ausführen und anschließend Build.command." >&2
    exit 1
fi
signing_options=()
if [[ -f "$private_key" ]]; then
    stored_key="$(xcrun swift -Xfrontend -disable-sandbox -module-cache-path "$release_root/../.build-QuickOrbit/ModuleCache" "$release_root/Tools/CreateSigningKey.swift" "$private_key")"
    signing_options=(--ed-key-file "$private_key")
else
    stored_key="$("$release_root/Vendor/Sparkle/bin/generate_keys" --account QuickOrbit -p)"
    signing_options=(--account QuickOrbit)
fi
if [[ "$key" != "$stored_key" ]]; then
    echo "Der Updateschlüssel im Schlüsselbund passt nicht zur App." >&2
    exit 1
fi
if [[ ! -f "$archive" || ! -f "$notes" ]]; then
    echo "App-ZIP oder Versionshinweise fehlen. Zuerst Build.command ausführen." >&2
    exit 1
fi
feed_stage="$(mktemp -d "${TMPDIR:-/private/tmp}/quickorbit-feed.XXXXXX")"
trap '/bin/rm -rf "$feed_stage"' EXIT
/usr/bin/unzip -q "$archive" 'QuickOrbit.app/Contents/Info.plist' -d "$feed_stage"
built_plist="$feed_stage/QuickOrbit.app/Contents/Info.plist"
built_key="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$built_plist" 2>/dev/null || true)"
built_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$built_plist")"
if [[ "$built_key" != "$key" || "$built_version" != "$version" ]]; then
    echo "Die ZIP passt nicht zum aktuellen Schlüssel oder zur Version. Zuerst Build.command ausführen." >&2
    exit 1
fi
attributes="$("$release_root/Vendor/Sparkle/bin/sign_update" "${signing_options[@]}" "$archive")"
xcrun swift -Xfrontend -disable-sandbox -module-cache-path "$release_root/../.build-QuickOrbit/ModuleCache" \
    "$release_root/Tools/CreateAppcast.swift" "$repository" "$version" "$attributes" "$notes" "$feed_stage/appcast.xml"
"$release_root/Vendor/Sparkle/bin/sign_update" "${signing_options[@]}" "$feed_stage/appcast.xml"
/usr/bin/xmllint --noout "$feed_stage/appcast.xml"
"$release_root/Vendor/Sparkle/bin/sign_update" "${signing_options[@]}" --verify "$feed_stage/appcast.xml"
mkdir -p "$release_root/Updates"
cp "$feed_stage/appcast.xml" "$release_root/Updates/appcast.xml"
echo "Signierter Update-Feed: $release_root/Updates/appcast.xml"
