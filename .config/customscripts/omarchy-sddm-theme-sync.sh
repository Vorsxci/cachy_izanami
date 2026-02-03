#!/bin/bash
# Sync Omarchy theme name to SDDM Astronaut theme

# Path to Omarchy "current theme"
OMARCHY_CURRENT="$HOME/.config/omarchy/current/theme"

# Extract the theme name (basename of the symlink target)
THEME_NAME=$(basename "$(readlink -f "$OMARCHY_CURRENT")")

# Where Astronaut keeps theme configs
SDDM_THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme/Themes"

# Build target path
TARGET_CONF="$SDDM_THEME_DIR/$THEME_NAME.conf"
CURRENT_CONF="$SDDM_THEME_DIR/current.conf"

# Safety check
if [[ ! -f "$TARGET_CONF" ]]; then
    echo "[ERROR] No config found for theme: $TARGET_CONF"
    exit 1
fi

# Update symlink
sudo ln -sf "$TARGET_CONF" "$CURRENT_CONF"
echo "[INFO] SDDM theme synced → $TARGET_CONF"

notify-send "SDDM theme synced → $TARGET_CONF"
