#!/usr/bin/env bash
# Waybar Battery Bar (btop-style) — fixed for Waybar ≥0.14
# Includes shine animation, safe tick handling, and color env support

segments=10
block="█"

# Colors (env overrides)
FILLED="${BAT_FILLED:-#a0cfdc}"
EMPTY="${BAT_EMPTY:-#3c3f4a}"
SHINE="${BAT_SHINE:-#ffffff}"
TEXT="${BAT_TEXT:-#a0cfdc}"

# Battery info
cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
stat=$(cat /sys/class/power_supply/BAT*/status   2>/dev/null | head -n1)
cap=${cap:-0}

# Detect AC (Charging)
ac_online=0
for p in /sys/class/power_supply/*; do
  if [ -f "$p/online" ] && [ "$(cat "$p/online" 2>/dev/null)" = "1" ]; then
    ac_online=1
    break
  fi
done

filled=$(( cap * segments / 100 ))
(( filled < 0 )) && filled=0
(( filled > segments )) && filled=$segments

# Animate only if charging
animate=0
if echo "$stat" | grep -qi "^Charging$"; then
  animate=1
fi

# Persistent tick
tickfile="$HOME/.cache/waybar_batterybar_tick"
mkdir -p "$(dirname "$tickfile")"

# Self-heal if wrong perms or directory
if [ -d "$tickfile" ]; then
  rm -rf "$tickfile"
fi

tick=0
max_tick=$(( segments * 1 ))  # smooth 4× sweep speed

if (( animate == 1 )); then
  if [ -r "$tickfile" ]; then
    read -r tick < "$tickfile"
  fi
  tick=$(( (tick + 1) % max_tick ))
  echo "$tick" > "$tickfile.tmp"
  mv "$tickfile.tmp" "$tickfile"
else
  rm -f "$tickfile" 2>/dev/null
fi

# Build bar
bar=""
for ((i=0; i<segments; i++)); do
  if (( i < filled )); then
    if (( animate == 1 && i == tick )); then
      bar+="<span foreground='$SHINE'>$block</span>"
    else
      bar+="<span foreground='$FILLED'>$block</span>"
    fi
  else
    bar+="<span foreground='$EMPTY'>$block</span>"
  fi
done

# Timestamp breaks caching (ensures visible update)
timestamp=$(date +%s%3N)
printf "%s <span foreground='%s'>%s%%</span><!--%s-->\n" "$bar" "$TEXT" "$cap" "$timestamp"

