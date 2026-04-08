#!/bin/bash
# Installa il tema ii-material-sddm se SDDM è installato

THEME_NAME="ii-material-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Controlla SDDM
if ! command -v sddm &>/dev/null && ! command -v sddm-greeter-qt6 &>/dev/null; then
    echo "SDDM non è installato, niente da fare."
    exit 0
fi

# Richiede root
if [ "$EUID" -ne 0 ]; then
    echo "Serve root. Uso sudo..."
    exec sudo bash "$SCRIPT_DIR/install.sh" "$@"
fi

# Installa file del tema
echo "Installazione tema in $THEME_DIR..."
mkdir -p "$THEME_DIR/Components" "$THEME_DIR/Backgrounds"
cp "$SCRIPT_DIR"/Main.qml "$THEME_DIR/"
cp "$SCRIPT_DIR"/metadata.desktop "$THEME_DIR/"
cp "$SCRIPT_DIR"/theme.conf "$THEME_DIR/"
cp "$SCRIPT_DIR"/colors.json "$THEME_DIR/" 2>/dev/null
cp "$SCRIPT_DIR"/translations.js "$THEME_DIR/" 2>/dev/null
cp "$SCRIPT_DIR"/Components/*.qml "$THEME_DIR/Components/"
cp "$SCRIPT_DIR"/Backgrounds/* "$THEME_DIR/Backgrounds/" 2>/dev/null
chmod -R a+rX "$THEME_DIR"

# Installa script sync matugen
echo "Installazione script sync matugen..."
cp "$SCRIPT_DIR/scripts/sync-sddm.sh" /usr/local/bin/sddm-matugen-sync
chmod +x /usr/local/bin/sddm-matugen-sync
echo "✓ Installato: /usr/local/bin/sddm-matugen-sync"

# Configura SDDM: tema + variabile d'ambiente
SDDM_CONF="/etc/sddm.conf.d/ii-material-sddm.conf"
mkdir -p /etc/sddm.conf.d
echo "Configurazione SDDM..."
cat > "$SDDM_CONF" <<'EOF'
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1

[Theme]
Current=ii-material-sddm
EOF

# Aggiorna /etc/sddm.conf se esiste con un altro tema
if [ -f /etc/sddm.conf ] && grep -q '^\s*Current=' /etc/sddm.conf; then
    sed -i 's/^\(\s*\)Current=.*/\1Current=ii-material-sddm/' /etc/sddm.conf
fi

echo ""
echo "✓ Tema $THEME_NAME installato e abilitato."
echo ""
echo "Per sincronizzare i colori e il wallpaper di matugen:"
echo "  sudo sddm-matugen-sync"
echo ""
echo "Riavvia SDDM con: sudo systemctl restart sddm"
