#!/bin/bash
# Sincronizza colori matugen e wallpaper attivo nel tema SDDM.
# Da eseguire dopo ogni cambio wallpaper/tema matugen.
# Richiede sudo per scrivere in /usr/share/sddm/themes/.
#
# Uso:
#   sudo sync-sddm.sh
#   sudo sync-sddm.sh --user mario   # specifica utente manualmente

THEME_NAME="ii-material-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

# Determina utente
if [[ "$1" == "--user" && -n "$2" ]]; then
    TARGET_USER="$2"
elif [[ -n "$SUDO_USER" ]]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER=$(logname 2>/dev/null || echo "$USER")
fi

USER_HOME=$(eval echo "~$TARGET_USER")
MATUGEN_COLORS="$USER_HOME/.local/state/quickshell/user/generated/colors.json"
MATUGEN_WALLPAPER="$USER_HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"

# Controlla permessi
if [[ "$EUID" -ne 0 ]]; then
    echo "Serve root. Riavvio con sudo..."
    exec sudo bash "$0" "$@"
fi

if [[ ! -d "$THEME_DIR" ]]; then
    echo "Errore: tema non installato in $THEME_DIR"
    echo "Esegui prima: sudo ./install.sh"
    exit 1
fi

# Sincronizza colors.json
if [[ -f "$MATUGEN_COLORS" ]]; then
    cp "$MATUGEN_COLORS" "$THEME_DIR/colors.json"
    echo "✓ Colori aggiornati da $MATUGEN_COLORS"
else
    echo "⚠ colors.json matugen non trovato: $MATUGEN_COLORS"
fi

# Sincronizza wallpaper
if [[ -f "$MATUGEN_WALLPAPER" ]]; then
    WALLPAPER_PATH=$(cat "$MATUGEN_WALLPAPER" | tr -d '\n')
    if [[ -f "$WALLPAPER_PATH" ]]; then
        EXT="${WALLPAPER_PATH##*.}"
        DEST="$THEME_DIR/Backgrounds/active.$EXT"
        cp "$WALLPAPER_PATH" "$DEST"
        # Aggiorna theme.conf con il nuovo background
        sed -i "s|^Background=.*|Background=Backgrounds/active.$EXT|" "$THEME_DIR/theme.conf"
        echo "✓ Wallpaper aggiornato: $WALLPAPER_PATH"
    else
        echo "⚠ Wallpaper non trovato: $WALLPAPER_PATH"
    fi
else
    echo "⚠ path.txt matugen non trovato: $MATUGEN_WALLPAPER"
fi

chmod -R a+rX "$THEME_DIR"
echo "✓ Permessi aggiornati"
echo "Fatto. Riavvia SDDM con: sudo systemctl restart sddm"
