#!/usr/bin/env bash
set -euo pipefail
command -v dart >/dev/null || { echo "dart introuvable dans le PATH" >&2; exit 1; }
cd "$(dirname "$0")/.."

version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
arch=amd64
out="build/$version"
pkg="$out/pkg/vigie_${version}_${arch}"

rm -rf "$pkg"
mkdir -p "$pkg/DEBIAN" "$pkg/usr/bin"

dart pub get --enforce-lockfile
dart compile exe bin/vigie.dart -o "$pkg/usr/bin/vigie"
cp "$pkg/usr/bin/vigie" "$out/vigie-linux-x64"     # binaire seul, pour la release GitHub

cat > "$pkg/DEBIAN/control" <<EOF
Package: vigie
Version: $version
Section: admin
Priority: optional
Architecture: $arch
Depends: bash, systemd, procps, passwd
Maintainer: Nuage <joachinloison@outlook.fr>
Homepage: https://github.com/nuageeee/vigie
Description: Manage a Linux server from a single terminal window
 Vigie brings user, process and systemd service management together
 in a terminal interface (TUI), with a built-in shell.
EOF

dpkg-deb --build --root-owner-group "$pkg" "$out/"
echo "✓ $out/vigie_${version}_${arch}.deb"