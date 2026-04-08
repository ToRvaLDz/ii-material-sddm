#!/bin/bash
# Crea il tarball per KDE Store / GHNS
# Uso: ./packaging/make-release.sh [versione]
# Esempio: ./packaging/make-release.sh 1.0

VERSION="${1:-1.0}"
THEME_NAME="ii-material-sddm"
ARCHIVE="${THEME_NAME}-${VERSION}.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Creazione $ARCHIVE..."

tar -czf "$SCRIPT_DIR/$ARCHIVE" \
    -C "$SCRIPT_DIR" \
    --transform "s|^\.|$THEME_NAME|" \
    ./Main.qml \
    ./metadata.desktop \
    ./theme.conf \
    ./colors.json \
    ./translations.js \
    ./preview.png \
    ./Components \
    ./Backgrounds

echo "✓ $ARCHIVE creato in $SCRIPT_DIR"
echo ""
echo "Carica su KDE Store: https://store.kde.org/upload"
echo "Categoria: SDDM Login Themes"
