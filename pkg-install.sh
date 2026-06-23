#!/usr/bin/env bash
# pkg-install.sh — install cachy_izanami packages
# https://github.com/Vorsxci/cachy_izanami

set -e

PACKAGES=(
  # Terminal / shell
  kitty starship zoxide

  # Fonts
  awesome-terminal-fonts cantarell-fonts inter-font
  noto-fonts noto-fonts-cjk noto-fonts-emoji otf-san-francisco
  ttf-bitstream-vera ttf-cascadia-code-nerd ttf-dejavu ttf-google-sans
  ttf-liberation ttf-meslo-nerd ttf-opensans ttf-roboto ttf-zen-maru-gothic

  # Hyprland ecosystem
  hypridle hyprpicker hyprsunset
  waybar swaybg swaync swayosd elephant elephant-desktopapplications
  elephant-menus elephant-providerlist elephant-todo
  walker wofi quickshell
  grim slurp satty wayfreeze-git wev wlr-randr
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk uwsm
  mpvpaper

  # Audio / video
  cava pavucontrol playerctl wiremix sof sof-firmware
  gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly
  vlc-plugins-all gpu-screen-recorder pipewire-alsa pipewire-pulse

  # Bluetooth
  bluetui bluez

  # Display / input
  brightnessctl fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-mozc fcitx5-qt

  # Apps
  chromium obsidian libreoffice-fresh
  nautilus meld zoom zotero spotify spotify-player
  glances duf fastfetch downgrade plocate ripgrep

  # Dev tools
  github-cli gitty neovim micro
  npm rust llvm python python-defusedxml python-packaging
  python-pyqt5 python-reportlab stow qt5-declarative
  qt5-quickcontrols2 qtmpris

  # Printing
  cups cups-filters cups-pdf
  foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds
  foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-ppds
  ghostscript gsfonts gutenprint hplip splix system-config-printer

  # Networking / remote
  logmein-hamachi networkmanager-openvpn sshfs waypipe wayvnc
  impala

  # Misc system
  cpupower polkit-kde-agent power-profiles-daemon ufw
  yaru-icon-theme gum pv btop
)

echo "==> Installing packages..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
echo "==> Done!"
