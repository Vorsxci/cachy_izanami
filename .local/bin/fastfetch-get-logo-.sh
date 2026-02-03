#!/bin/bash

THEME_DIR="$HOME/.config/omarchy/current/theme"
THEME_NAME=$(basename "$(readlink -f "$THEME_DIR")" | tr '[:upper:]' '[:lower:]')

case "$THEME_NAME" in
lunr)
  echo "$HOME/.config/fastfetch/LunrAsciiBasev2.txt"
  ;;
solr)
  echo "$HOME/.config/fastfetch/solr-ascii.txt"
  ;;
*)
  echo "arch"
  ;;
esac
