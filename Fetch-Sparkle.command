#!/bin/zsh
set -euo pipefail

release_root="${0:A:h}"
vendor_root="$release_root/Vendor/Sparkle"
if [[ -d "$vendor_root/Sparkle.framework" && -x "$vendor_root/bin/sign_update" ]]; then
    exit 0
fi

archive="$(mktemp "${TMPDIR:-/private/tmp}/quickorbit-sparkle.XXXXXX")"
stage="$(mktemp -d "${TMPDIR:-/private/tmp}/quickorbit-sparkle-unpack.XXXXXX")"
trap '/bin/rm -f "$archive"; /bin/rm -rf "$stage"' EXIT
curl --fail --location --retry 3 --output "$archive" \
    'https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-2.10.0.tar.xz'
actual="$(shasum -a 256 "$archive" | awk '{print $1}')"
expected='c2bf58aa8387266ac179357b1415d6f2635f044da8be41042af32425dae6da0c'
if [[ "$actual" != "$expected" ]]; then
    echo "Sparkle-Prüfsumme stimmt nicht. Download wird nicht verwendet." >&2
    exit 1
fi
tar -xJf "$archive" -C "$stage"
if [[ ! -d "$stage/Sparkle.framework" || ! -x "$stage/bin/sign_update" || ! -f "$stage/LICENSE" ]]; then
    echo "Sparkle-Archiv ist unvollständig." >&2
    exit 1
fi
mkdir -p "$release_root/Vendor"
/bin/mv "$stage" "$vendor_root"
echo "Sparkle 2.10.0 geprüft und lokal bereitgestellt."
