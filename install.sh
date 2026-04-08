#!/bin/bash
# Install ii-sddm theme if SDDM is installed

THEME_NAME="ii-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if SDDM is installed
if ! command -v sddm &>/dev/null && ! command -v sddm-greeter-qt6 &>/dev/null; then
    echo "SDDM non è installato, niente da fare."
    exit 0
fi

# Need root
if [ "$EUID" -ne 0 ]; then
    echo "Serve root. Uso sudo..."
    exec sudo bash "$SCRIPT_DIR/install.sh" "$@"
fi

# Install theme files
echo "Installazione tema in $THEME_DIR..."
mkdir -p "$THEME_DIR/Components" "$THEME_DIR/Backgrounds"
cp "$SCRIPT_DIR"/Main.qml "$THEME_DIR/"
cp "$SCRIPT_DIR"/metadata.desktop "$THEME_DIR/"
cp "$SCRIPT_DIR"/theme.conf "$THEME_DIR/"
cp "$SCRIPT_DIR"/colors.json "$THEME_DIR/" 2>/dev/null
cp "$SCRIPT_DIR"/Components/*.qml "$THEME_DIR/Components/"
cp "$SCRIPT_DIR"/Backgrounds/* "$THEME_DIR/Backgrounds/" 2>/dev/null
chmod -R a+rX "$THEME_DIR"

# Configure SDDM: theme + env variable
SDDM_CONF="/etc/sddm.conf.d/ii-sddm.conf"
mkdir -p /etc/sddm.conf.d
echo "Configurazione SDDM..."
cat > "$SDDM_CONF" <<'EOF'
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1

[Theme]
Current=ii-sddm
EOF

# Aggiorna /etc/sddm.conf se esiste con un altro tema
if [ -f /etc/sddm.conf ] && grep -q '^\s*Current=' /etc/sddm.conf; then
    sed -i 's/^\(\s*\)Current=.*/\1Current=ii-sddm/' /etc/sddm.conf
fi

echo "Tema $THEME_NAME installato e abilitato."
echo "Riavvia SDDM con: sudo systemctl restart sddm"
