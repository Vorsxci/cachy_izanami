#!/usr/bin/env bash
# fetch-calendars.sh — fetches ICS calendars defined in .conf files
# Called by EventsSection.qml on startup and every 15 minutes

CALENDAR_DIR="/home/kazuki/.config/quickshell/center-panel"

for cal in canvasCal eventsCal meetingsCal; do
  conf="$CALENDAR_DIR/${cal}.conf"
  dest="$CALENDAR_DIR/${cal}"

  [[ -f "$conf" ]] || continue

  # Source the .conf to get ICS_URL
  source "$conf"

  [[ -z "$ICS_URL" ]] && continue

  # Fetch and write atomically
  tmp="$(mktemp)"
  if curl -fsSL --max-time 30 "$ICS_URL" -o "$tmp"; then
    mv "$tmp" "$dest"
  else
    rm -f "$tmp"
  fi

  unset ICS_URL
done
