#!/bin/bash
# Installa il tema ii-material-sddm e configura i permessi per matugen

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

# Determina l'utente reale (chi ha invocato sudo)
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
USER_HOME=$(eval echo "~$TARGET_USER")

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

# Permessi matugen: concede a sddm la lettura della cartella state
# senza toccare il resto della home (usa ACL per granularità)
MATUGEN_STATE="$USER_HOME/.local/state/quickshell/user/generated"
if command -v setfacl &>/dev/null; then
    echo "Configurazione ACL per accesso sddm ai file matugen..."
    # Traversal dalla home fino a quickshell
    for dir in \
        "$USER_HOME" \
        "$USER_HOME/.local" \
        "$USER_HOME/.local/state" \
        "$USER_HOME/.local/state/quickshell" \
        "$USER_HOME/.local/state/quickshell/user" \
        "$USER_HOME/.local/state/quickshell/user/generated"
    do
        [ -d "$dir" ] && setfacl -m u:sddm:--x "$dir"
    done
    # Lettura ricorsiva dei file generati
    if [ -d "$MATUGEN_STATE" ]; then
        setfacl -Rm u:sddm:r-- "$MATUGEN_STATE"
        setfacl -Rm d:u:sddm:r-- "$MATUGEN_STATE"   # default ACL per file futuri
        echo "✓ ACL configurati su $MATUGEN_STATE"
    else
        echo "⚠ Cartella matugen non trovata: $MATUGEN_STATE"
        echo "  Esegui matugen almeno una volta, poi rilancia install.sh"
    fi
else
    echo "⚠ setfacl non disponibile (pacchetto: acl)"
    echo "  Installa acl e rilancia install.sh per il supporto matugen automatico"
fi

# Configura SDDM
SDDM_CONF="/etc/sddm.conf.d/ii-material-sddm.conf"
mkdir -p /etc/sddm.conf.d
echo "Configurazione SDDM..."
cat > "$SDDM_CONF" <<'EOF'
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1

[Theme]
Current=ii-material-sddm
EOF

# Aggiorna /etc/sddm.conf se già esiste con un altro tema
if [ -f /etc/sddm.conf ] && grep -q '^\s*Current=' /etc/sddm.conf; then
    sed -i 's/^\(\s*\)Current=.*/\1Current=ii-material-sddm/' /etc/sddm.conf
fi

echo ""
echo "✓ Tema $THEME_NAME installato."
echo "Riavvia SDDM con: sudo systemctl restart sddm"
