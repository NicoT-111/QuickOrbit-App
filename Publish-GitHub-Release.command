#!/bin/zsh
set -euo pipefail

release_root="${0:A:h}"
repository="NicoT-111/QuickOrbit-App"
info_plist="$release_root/Packaging/Info.plist"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$info_plist")"
tag="v$version"
archive="$release_root/QuickOrbit-v${version}.zip"
notes="$release_root/GitHub-Release/ReleaseNotes-v${version}.md"

if [[ ! -f "$notes" ]]; then
    echo "Versionshinweise fehlen: $notes" >&2
    exit 1
fi

"$release_root/Build.command"
"$release_root/Generate-Update-Feed.command"
feed="$release_root/Updates/appcast.xml"

echo ""
echo "GitHub Release ist lokal vorbereitet:"
echo "  App:      $archive"
echo "  Hinweise: $notes"
echo "  Update-Feed: $feed"

if [[ "${1:-}" != "--publish" ]]; then
    echo ""
    echo "Es wurde nichts hochgeladen. Nach der Kontrolle veröffentlichen mit:"
    echo "  $release_root/Publish-GitHub-Release.command --publish"
    exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) fehlt. Installiere sie und melde dich mit 'gh auth login' an." >&2
    exit 1
fi
gh auth status >/dev/null

if gh release view "$tag" --repo "$repository" >/dev/null 2>&1; then
    echo "Dieser Tag ist bereits veröffentlicht. Für Updates immer eine neue Versionsnummer verwenden." >&2
    exit 1
else
    gh release create "$tag" "$archive" "$feed" --repo "$repository" --title "QuickOrbit $tag" --notes-file "$notes" --latest
fi

echo ""
echo "QuickOrbit $tag und der signierte Update-Feed wurden veröffentlicht."
echo "https://github.com/$repository/releases/tag/$tag"
