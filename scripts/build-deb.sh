#!/usr/bin/env bash
set -euo pipefail
export PATH="$PATH:/usr/lib/dart/bin"
cd "$(dirname "$0")/.."

version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
arch=amd64
out="build/$version"
pkg="$out/pkg/vigie_${version}_${arch}"

rm -rf "$pkg"
mkdir -p "$pkg/DEBIAN" "$pkg/usr/bin"

dart pub get
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
Description: Gérer un serveur Linux depuis une seule fenêtre de terminal
 Vigie regroupe la gestion des utilisateurs, des processus et des
 services systemd dans une interface terminal (TUI), avec un shell intégré.
EOF

dpkg-deb --build --root-owner-group "$pkg" "$out/"
echo "✓ $out/vigie_${version}_${arch}.deb"