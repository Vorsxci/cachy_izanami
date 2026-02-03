#!/usr/bin/env bash
set -euo pipefail

ANGLE="45deg"
ALPHA="ff"
SLEEP="0.05"              # slower -> increase (0.12, 0.15, 0.20)
STEPS_PER_SEGMENT=24      # smoother -> increase (16–48)

# Your theme anchors (hex, no alpha)
A0="605a80"
A1="afc5da"
A2="fefbd0"

command -v hyprctl >/dev/null || { echo "hyprctl not found"; exit 1; }
command -v python3 >/dev/null || { echo "python3 not found"; exit 1; }

if [[ "${STEPS_PER_SEGMENT}" -lt 2 ]]; then
  echo "STEPS_PER_SEGMENT must be >= 2"
  exit 1
fi

# Build palette with python (simple + reliable)
mapfile -t PALETTE < <(python3 - "$A0" "$A1" "$A2" "$STEPS_PER_SEGMENT" <<'PY'
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
)

N="${#PALETTE[@]}"
if [[ "$N" -lt 6 ]]; then
  echo "Palette build failed (N=$N). Check your hex colors and STEPS_PER_SEGMENT."
  exit 1
fi

idx=0
while true; do
  c1="${PALETTE[$(( idx % N ))]}"
  c2="${PALETTE[$(( (idx + N/6) % N ))]}"
  c3="${PALETTE[$(( (idx + N/3) % N ))]}"

   # Pick which color to drive the glow:
  # - c2 tends to look nicest (it's the "middle" gradient stop)
  GLOW="${c2}"

  # Make glow slightly transparent (so it reads like light, not a hard shadow)
  GLOW_ALPHA="88"   # try: 66 (subtle), 88 (nice), aa (strong)

  hyprctl --batch "\
keyword general:col.active_border rgba(${c1}${ALPHA}) rgba(${c2}${ALPHA}) rgba(${c3}${ALPHA}) ${ANGLE}; \
keyword decoration:shadow:color rgba(${GLOW}${GLOW_ALPHA}); \
" >/dev/null 2>&1 || true


  idx=$((idx + 1))
  sleep "$SLEEP"
done

