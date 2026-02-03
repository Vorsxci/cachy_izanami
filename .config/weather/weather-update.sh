#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/weather/weather.conf"
# Defaults if config missing
MODE="city"
CITY="Indianapolis"
LAT="39.7684"
LON="-86.1581"

if [[ -f "$CFG" ]]; then
  # shellcheck disable=SC1090
  source "$CFG"
fi

CACHE_DIR="$HOME/.cache/weather"
OUT_FILE="$CACHE_DIR/weather_out.txt"
mkdir -p "$CACHE_DIR"

# --- Fetch from Open-Meteo (no key), ALWAYS Celsius
# We need weather_code + temperature_2m
if [[ "${MODE}" == "coords" ]]; then
  url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code&temperature_unit=celsius"
else
  # Resolve CITY -> LAT/LON via Open-Meteo geocoding (no key)
  geo="https://geocoding-api.open-meteo.com/v1/search?name=$(printf '%s' "$CITY" | sed 's/ /%20/g')&count=1&language=en&format=json"
  geo_json="$(
    /usr/bin/curl -4 -fsS --connect-timeout 2 --max-time 4 -A "hyprlock-weather/1.0" \
      "$geo" 2>/dev/null || true
  )"
  lat="$(echo "$geo_json" | grep -oE '"latitude":[-0-9.]+' | head -n1 | cut -d: -f2 || true)"
  lon="$(echo "$geo_json" | grep -oE '"longitude":[-0-9.]+' | head -n1 | cut -d: -f2 || true)"

  [[ -z "$lat" || -z "$lon" ]] && exit 0
  url="https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code&temperature_unit=celsius"
fi

json="$(
  /usr/bin/curl -4 -fsS --connect-timeout 2 --max-time 4 -A "hyprlock-weather/1.0" \
    "$url" 2>/dev/null || true
)"
[[ -z "$json" ]] && exit 0

t="$(echo "$json" | grep -oE '"temperature_2m":[-0-9.]+' | head -n1 | cut -d: -f2 || true)"
code="$(echo "$json" | grep -oE '"weather_code":[0-9]+' | head -n1 | cut -d: -f2 || true)"
[[ -z "$t" || -z "$code" ]] && exit 0

t_int="$(printf "%.0f" "$t" 2>/dev/null || echo "")"
[[ -z "$t_int" ]] && exit 0
temp="${t_int}°C"

# Map Open-Meteo weather codes to buckets
bucket="cloudy"
if [[ "$code" == "0" ]]; then
  bucket="sunny"
elif [[ "$code" =~ ^(51|53|55|56|57|61|63|65|66|67|80|81|82|95|96|99)$ ]]; then
  bucket="rain"
elif [[ "$code" =~ ^(71|73|75|77|85|86)$ ]]; then
  bucket="snow"
fi

echo "${bucket}|${temp}" > "$OUT_FILE"

