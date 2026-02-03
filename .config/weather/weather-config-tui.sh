#!/usr/bin/env bash
set -euo pipefail

CONF="$HOME/.config/weather/weather.conf"
SERVICE="weather-update.service"

# Defaults if file missing
MODE="city"
CITY="Indianapolis"
LAT="39.7684"
LON="-86.1581"

# Load existing config (best-effort)
if [[ -f "$CONF" ]]; then
  # shellcheck disable=SC1090
  source "$CONF" || true
fi

save_conf() {
  mkdir -p "$(dirname "$CONF")"
  cat > "$CONF" <<EOF
# Choose ONE mode:
#   MODE=city   -> uses CITY
#   MODE=coords -> uses LAT/LON
MODE=${MODE}

# City mode (examples: "Paris", "San Francisco", "Tokyo", "New York")
CITY="${CITY}"

# Coords mode
LAT="${LAT}"
LON="${LON}"
EOF
}

refresh() {
  # Update cache now
  systemctl --user start "$SERVICE" >/dev/null 2>&1 || true
  # Ask waybar to reload modules
  pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
}

header() {
  clear
  echo "Weather config changer (for hyprlock + waybar)"
  echo "------------------------------------"
  echo "MODE : ${MODE}"
  echo "CITY : ${CITY}"
  echo "COORD: ${LAT}, ${LON}"
  echo
}

while true; do
  header
  echo "1) Set mode: city"
  echo "2) Set mode: coords"
  echo "3) Edit city string"
  echo "4) Edit latitude/longitude"
  echo "5) Save + refresh"
  echo "6) Quit"
  echo
  read -r -p "Select: " choice

  case "$choice" in
    1) MODE="city" ;;
    2) MODE="coords" ;;
    3)
      read -r -p "City (e.g. Tokyo): " in
      [[ -n "${in// }" ]] && CITY="$in"
      ;;
    4)
      read -r -p "Latitude  (e.g. 39.7684): " inlat
      read -r -p "Longitude (e.g. -86.1581): " inlon
      [[ -n "${inlat// }" ]] && LAT="$inlat"
      [[ -n "${inlon// }" ]] && LON="$inlon"
      ;;
    5)
      save_conf
      refresh
      echo
      echo "Saved to: $CONF"
      echo "Cache refreshed + Waybar signaled."
      read -r -p "Press Enter to close..."
      exit 0
      ;;
    6|q|Q) exit 0 ;;
    *) ;;
  esac
done

