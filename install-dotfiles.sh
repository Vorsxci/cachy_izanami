#!/usr/bin/env bash
# install-dotfiles.sh — copy cachy_izanami dotfiles into place
# https://github.com/Vorsxci/cachy_izanami

set -e

REPO_URL="https://github.com/Vorsxci/cachy_izanami.git"
DOTFILES_DIR="$HOME/.dotfiles/cachy_izanami"

# ── Clone / update ────────────────────────────────────────────────────────────

echo "==> Fetching dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  echo "    Pulling latest..."
  git -C "$DOTFILES_DIR" pull
else
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# ── Copy files ────────────────────────────────────────────────────────────────

echo "==> Copying dotfiles..."

# .bashrc / .aliases
cp -f "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
cp -f "$DOTFILES_DIR/.aliases" "$HOME/.aliases"

# .config/* → ~/.config/
if [ -d "$DOTFILES_DIR/.config" ]; then
  cp -rf "$DOTFILES_DIR/.config/." "$HOME/.config/"
  echo "    Copied .config"
fi

# bin/ → ~/.local/bin/
if [ -d "$DOTFILES_DIR/bin" ]; then
  mkdir -p "$HOME/.local/bin"
  cp -rf "$DOTFILES_DIR/bin/." "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/"*
  echo "    Copied bin"
fi

# sddm-themes → /usr/share/sddm/themes/
if [ -d "$DOTFILES_DIR/sddm-themes" ]; then
  echo "==> Installing SDDM themes (requires sudo)..."
  sudo cp -rf "$DOTFILES_DIR/sddm-themes/." "/usr/share/sddm/themes/"
  echo "    Copied sddm-themes"
fi

# -- Start services ----------------------------------
systemctl --user enable --now elephant.service
systemctl --user enable --now omarchy-battery-monitor.timer
systemctl --user enable --now weather-update.timer

# ── Done ──────────────────────────────────────────────────────────────────────

echo "==> Done!"
echo "    Run: source ~/.bashrc"
echo "    Log out and back in for SDDM + session changes to apply."
