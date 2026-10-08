#!/bin/zsh
set -euo pipefail
release_root="${0:A:h}"
key_tool="$release_root/Vendor/Sparkle/bin/generate_keys"
plist="$release_root/Packaging/Info.plist"
private_key="${QUICKORBIT_UPDATE_KEY_FILE:-$release_root/../../../../.quickorbit-signing/QuickOrbit-ed25519.key}"

echo "Einmalige Einrichtung der signierten QuickOrbit-Updates."
echo "Der private Schlüssel bleibt lokal und wird niemals veröffentlicht."
if [[ -f "$private_key" ]]; then
    public_key="$(xcrun swift -Xfrontend -disable-sandbox -module-cache-path "$release_root/../.build-QuickOrbit/ModuleCache" "$release_root/Tools/CreateSigningKey.swift" "$private_key")"
elif "$key_tool" --account QuickOrbit; then
    public_key="$("$key_tool" --account QuickOrbit -p)"
else
    echo "Schlüsselbund nicht verfügbar; privater Schlüssel wird geschützt außerhalb des Release-Ordners gespeichert."
    public_key="$(xcrun swift -Xfrontend -disable-sandbox -module-cache-path "$release_root/../.build-QuickOrbit/ModuleCache" "$release_root/Tools/CreateSigningKey.swift" "$private_key")"
fi
if [[ ! "$public_key" =~ '^[A-Za-z0-9+/]{43}=$' ]]; then
    echo "Der öffentliche Schlüssel konnte nicht gelesen werden." >&2
    exit 1
fi
existing_key="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$plist" 2>/dev/null || true)"
if [[ -n "$existing_key" && "$existing_key" != "$public_key" ]]; then
    echo "Die App enthält einen anderen Updateschlüssel. Keine automatische Überschreibung." >&2
    exit 1
fi
if [[ -z "$existing_key" ]]; then
    /usr/libexec/PlistBuddy -c "Add :SUPublicEDKey string $public_key" "$plist"
fi
echo "Fertig. QuickOrbit jetzt neu bauen und mit Publish-GitHub-Release.command veröffentlichen."
echo "Den privaten Schlüssel sichern und niemals auf GitHub hochladen."
if [[ -f "$private_key" ]]; then echo "Privaten Schlüssel sicher sichern: $private_key"; fi
