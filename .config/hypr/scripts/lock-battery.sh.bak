#!/usr/bin/env bash
set -euo pipefail

PART="${LOCK_BATT_PART:-full}"

BAT=""
for b in /sys/class/power_supply/BAT*; do
  [[ -d "$b" ]] && BAT="$b" && break
done
[[ -z "$BAT" ]] && exit 0

cap="$(cat "$BAT/capacity" 2>/dev/null || echo 0)"
stat="$(cat "$BAT/status" 2>/dev/null || echo Unknown)"

(( cap < 0 )) && cap=0
(( cap > 100 )) && cap=100

# ===== Geometry (defaults match your battery.conf container pill) =====
BAR_W="${BAR_W:-425}"
BAR_H="${BAR_H:-18}"
PAD="${PAD:-2}"

# Anchor (must match battery.conf bar center)
BAT_X="${BAT_X:-90}"
BAT_Y="${BAT_Y:- -475}"

INNER_W=$(( BAR_W - PAD*2 ))
INNER_H=$(( BAR_H - PAD*2 ))
FILL_W=$(( cap * INNER_W / 100 ))
(( FILL_W < 2 )) && FILL_W=2

LEFT_EDGE=$(( -INNER_W/2 + PAD ))
FILL_CENTER_X=$(( LEFT_EDGE + FILL_W/2 ))

FILL_ROUND=$(( (BAR_H/2) - PAD ))
(( FILL_ROUND < 1 )) && FILL_ROUND=1

CACHE_DIR="/home/kazuki/.cache/hyprlock"
CACHE_FILE="$CACHE_DIR/battery-fill.conf"
mkdir -p "$CACHE_DIR"

# Generate fill shape
cat > "$CACHE_FILE" <<EOF
shape {
  monitor =
  size = ${FILL_W}, ${INNER_H}
  rounding = ${FILL_ROUND}
  color = \$bar_fill
  position = $(( BAT_X + FILL_CENTER_X )), ${BAT_Y}
  halign = center
  valign = center
  zindex = 5
}
EOF

# ----- Text bits (Nerd Font glyphs only)

# Battery icons (Font Awesome via Nerd Fonts)
if (( cap >= 90 )); then icon=""
elif (( cap >= 65 )); then icon=""
elif (( cap >= 40 )); then icon=""
elif (( cap >= 15 )); then icon=""
else icon=""
fi

# Charging bolt (Nerd Font, NOT emoji)
bolt=""
[[ "$stat" == "Charging" ]] && bolt="󱐋"

case "$PART" in
  icon) echo "$icon" ;;
  bolt) echo "$bolt" ;;
  pct)  echo "${cap}%" ;;
  full) echo "$icon $bolt ${cap}%" ;;
  *)    echo "" ;;
esac

