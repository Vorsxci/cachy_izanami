#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar_clock_jp"

# Toggle state
if [[ "${1:-}" == "toggle" ]]; then
  if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
  else
    : > "$STATE_FILE"
  fi
  exit 0
fi

time_part="$(date +%H:%M)"

if [[ -f "$STATE_FILE" ]]; then
  # -------- Japanese format --------
  case "$(date +%u)" in
    1) weekday="月曜日" ;;
    2) weekday="火曜日" ;;
    3) weekday="水曜日" ;;
    4) weekday="木曜日" ;;
    5) weekday="金曜日" ;;
    6) weekday="土曜日" ;;
    7) weekday="日曜日" ;;
  esac

  date_jp="$(date +%Y年%m月%d日)"
  text="${date_jp} | ${weekday} | ${time_part}"
else
  # -------- English format --------
  weekday="$(LC_TIME=C date +%A)"
  date_en="$(date +%m/%d/%Y)"
  text="${date_en} | ${weekday} | ${time_part}"

fi

printf '{"text":"%s","tooltip":false}\n' "$text"

