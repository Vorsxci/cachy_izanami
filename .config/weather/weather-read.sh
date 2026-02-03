#!/usr/bin/env bash
set -euo pipefail

PART="${LOCK_WEATHER_PART:-full}"

CACHE_DIR="$HOME/.cache/weather"
OUT_FILE="$CACHE_DIR/weather_out.txt"

mkdir -p "$CACHE_DIR"

CFG="$HOME/.config/weather/weather.conf"

MODE="city"
CITY=""
LAT=""
LON=""

if [[ -f "$CFG" ]]; then
  # shellcheck disable=SC1090
  source "$CFG"
fi

# Tooltip text depending on mode
tooltip="weather"
if [[ "${MODE:-city}" == "coords" ]]; then
  if [[ -n "${LAT:-}" && -n "${LON:-}" ]]; then
    tooltip="📍 ${LAT}, ${LON}"
  else
    tooltip="📍 coords"
  fi
else
  # city mode
  if [[ -n "${CITY:-}" ]]; then
    tooltip="📍 ${CITY}"
  else
    tooltip="📍 city"
  fi
fi


bucket="cloudy"
temp="--°C"

if [[ -s "$OUT_FILE" ]]; then
  IFS='|' read -r bucket temp < "$OUT_FILE" || true
fi

SUN="󰖙"; CLOUD="󰖐"; RAIN="󰖗"; SNOW="󰖘"

case "$bucket" in
  sunny)  icon="$SUN" ;;
  cloudy) icon="$CLOUD" ;;
  rain)   icon="$RAIN" ;;
  snow)   icon="$SNOW" ;;
  *)      icon="$CLOUD" ;;
esac

case "$PART" in
  temp)   echo "$temp" ;;
  sunny)  [[ "$bucket" == "sunny"  ]] && echo "$SUN"   || echo "" ;;
  cloudy) [[ "$bucket" == "cloudy" ]] && echo "$CLOUD" || echo "" ;;
  rain)   [[ "$bucket" == "rain"   ]] && echo "$RAIN"  || echo "" ;;
  snow)   [[ "$bucket" == "snow"   ]] && echo "$SNOW"  || echo "" ;;
  json)
  text="${icon} ${temp}"
  cls="${bucket}"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$(printf '%s' "$text")" \
    "$(printf '%s' "$cls")" \
    "$(printf '%s' "$tooltip")"
  ;;

  full|*) echo "$icon $temp" ;;
esac

