#!/usr/bin/env bash
set -euo pipefail

# ---- Omarchy current theme bundle ----
CURRENT_THEME_DIR="$HOME/.config/omarchy/current/theme"

# ---- knobs ----
ANGLE="45deg"             # keep constant; we can auto-parse later if you want
BORDER_ALPHA="ff"
GLOW_ALPHA="88"           # 66 subtle, 88 nice, aa strong
SLEEP="0.1"              # slower -> increase (0.12–0.20)
STEPS_PER_SEGMENT=24      # smoother -> increase (16–48)
GLOW_EVERY=2              # update glow every N frames
RELOAD_EVERY=2            # seconds between checking for theme changes

command -v hyprctl >/dev/null || { echo "hyprctl not found"; exit 1; }
command -v python3 >/dev/null || { echo "python3 not found"; exit 1; }

[[ -d "$CURRENT_THEME_DIR" ]] || {
  echo "Current theme dir not found: $CURRENT_THEME_DIR"
  exit 1
}

# Find a file inside current theme that sets col.active_border
find_active_border_file() {
  # prefer obvious filenames if present
  local candidates=(
    "$CURRENT_THEME_DIR/hyprland.conf"
    "$CURRENT_THEME_DIR/hypr.conf"
    "$CURRENT_THEME_DIR/hypr/hyprland.conf"
    "$CURRENT_THEME_DIR/hypr/hypr.conf"
  )
  for f in "${candidates[@]}"; do
    [[ -f "$f" ]] && grep -qE '^\s*col\.active_border\s*=' "$f" && echo "$f" && return 0
  done

  # fallback: first file that mentions col.active_border
  local hit
  hit="$(grep -RIl --exclude-dir=.git --exclude='*.png' --exclude='*.jpg' \
        'col\.active_border' "$CURRENT_THEME_DIR" 2>/dev/null | head -n 1 || true)"
  [[ -n "$hit" ]] && echo "$hit" && return 0
  return 1
}

# Extract first 3 rgba(........) colors, strip alpha -> 6 hex chars
extract_three_hex6() {
  local file="$1"
  local line
  line="$(grep -E '^\s*col\.active_border\s*=' "$file" | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1

  local colors
  colors="$(echo "$line" \
    | grep -oE 'rgba\([0-9a-fA-F]{8}\)' \
    | sed -E 's/rgba\(([0-9a-fA-F]{6}).*\)/\1/' \
    | tr 'A-F' 'a-f' \
    | head -n 3)"

  local a b c
  a="$(echo "$colors" | sed -n '1p')"
  b="$(echo "$colors" | sed -n '2p')"
  c="$(echo "$colors" | sed -n '3p')"
  [[ -n "$a" && -n "$b" && -n "$c" ]] || return 1
  echo "$a" "$b" "$c"
}

build_palette_py() {
  local A0="$1" A1="$2" A2="$3" steps="$4"
  python3 - "$A0" "$A1" "$A2" "$steps" <<'PY'
import sys
A0, A1, A2, steps = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

def hex_to_rgb(h):
    h = h.strip().lstrip("#")
    return (int(h[0:2],16), int(h[2:4],16), int(h[4:6],16))

def rgb_to_hex(rgb):
    return f"{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}"

def lerp(a, b, t):
    return int(round(a + (b-a)*t))

def blend(h1, h2, t):
    r1,g1,b1 = hex_to_rgb(h1)
    r2,g2,b2 = hex_to_rgb(h2)
    return rgb_to_hex((lerp(r1,r2,t), lerp(g1,g2,t), lerp(b1,b2,t)))

anchors = [A0, A1, A2, A0]
out = []
for s,e in zip(anchors, anchors[1:]):
    for i in range(steps):
        t = i / float(steps)   # [0,1)
        out.append(blend(s,e,t))

for c in out:
    print(c)
PY
}

state=""
A0="605a80"; A1="afc5da"; A2="fefbd0"   # fallback defaults
N=0
PALETTE=()

refresh_palette() {
  local f
  f="$(find_active_border_file || true)"
  [[ -n "$f" ]] || { echo "Could not find any file in $CURRENT_THEME_DIR setting col.active_border"; exit 1; }

  local anchors
  anchors="$(extract_three_hex6 "$f" || true)"
  [[ -n "$anchors" ]] || { echo "Could not parse 3 rgba() colors from col.active_border in: $f"; exit 1; }

  read -r A0 A1 A2 <<<"$anchors"

  mapfile -t PALETTE < <(build_palette_py "$A0" "$A1" "$A2" "$STEPS_PER_SEGMENT")
  N="${#PALETTE[@]}"
  [[ "$N" -ge 6 ]] || { echo "Palette build failed (N=$N)"; exit 1; }

  # include file mtime so if theme changes in-place, we rebuild
  local mtime
  mtime="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
  state="${f}|${mtime}|${A0}${A1}${A2}|${STEPS_PER_SEGMENT}"
}

refresh_palette

idx=0
frame=0
last_check=0

while true; do
  now="$(date +%s)"
  if (( now - last_check >= RELOAD_EVERY )); then
    last_check="$now"

    f="$(find_active_border_file || true)"
    if [[ -n "$f" ]]; then
      mtime="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
      anchors="$(extract_three_hex6 "$f" || true)"
      if [[ -n "$anchors" ]]; then
        read -r x0 x1 x2 <<<"$anchors"
        new_state="${f}|${mtime}|${x0}${x1}${x2}|${STEPS_PER_SEGMENT}"
        if [[ "$new_state" != "$state" ]]; then
          refresh_palette
          idx=0
          frame=0
        fi
      fi
    fi
  fi

  # 7-stop gradient (much smoother + fewer edge pulses)
  o1=$(( (N*13)/100 ))
  o2=$(( (N*31)/100 ))
  o3=$(( (N*47)/100 ))
  o4=$(( (N*63)/100 ))
  o5=$(( (N*79)/100 ))
  o6=$(( (N*91)/100 ))

  c1="${PALETTE[$(( (idx + 0)  % N ))]}"
  c2="${PALETTE[$(( (idx + o1) % N ))]}"
  c3="${PALETTE[$(( (idx + o2) % N ))]}"
  c4="${PALETTE[$(( (idx + o3) % N ))]}"
  c5="${PALETTE[$(( (idx + o4) % N ))]}"
  c6="${PALETTE[$(( (idx + o5) % N ))]}"
  c7="${PALETTE[$(( (idx + o6) % N ))]}"

  # Use the “middle-ish” stop for glow
  GLOW="${c4}"

  frame=$((frame + 1))

  if (( frame % GLOW_EVERY == 0 )); then
      hyprctl --batch "\
keyword general:col.active_border rgba(${c1}${BORDER_ALPHA}) rgba(${c2}${BORDER_ALPHA}) rgba(${c3}${BORDER_ALPHA}) rgba(${c4}${BORDER_ALPHA}) rgba(${c5}${BORDER_ALPHA}) rgba(${c6}${BORDER_ALPHA}) rgba(${c7}${BORDER_ALPHA}) ${ANGLE}; \
keyword decoration:shadow:color rgba(${GLOW}${GLOW_ALPHA}); \
" >/dev/null 2>&1 || true
    else
    hyprctl keyword general:col.active_border \
      "rgba(${c1}${BORDER_ALPHA}) rgba(${c2}${BORDER_ALPHA}) rgba(${c3}${BORDER_ALPHA}) rgba(${c4}${BORDER_ALPHA}) rgba(${c5}${BORDER_ALPHA}) rgba(${c6}${BORDER_ALPHA}) rgba(${c7}${BORDER_ALPHA}) ${ANGLE}" \
      >/dev/null 2>&1 || true
  fi

  idx=$((idx + 1))
  sleep "$SLEEP"
done

