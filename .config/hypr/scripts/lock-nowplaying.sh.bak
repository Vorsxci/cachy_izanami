#!/usr/bin/env bash
set -u  # do NOT use -e or pipefail with playerctl

PART="${LOCK_NOW_PART:-text}"   # icon | text | status | player
MAX="${LOCK_NOW_MAX:-46}"

# Fallback when nothing is playing
fallback_icon="♪"
fallback_text="Nothing Playing"

command -v playerctl >/dev/null 2>&1 || {
  case "$PART" in
    icon) echo "$fallback_icon" ;;
    text) echo "$fallback_text" ;;
    *)    echo "" ;;
  esac
  exit 0
}

trim() {
  local s="$1"
  if [[ "${#s}" -gt "$MAX" ]]; then
    echo "${s:0:$((MAX-1))}…"
  else
    echo "$s"
  fi
}

player_icon() {
  local p="${1,,}"
  case "$p" in
    spotify*)   echo "" ;;
    firefox*)   echo "" ;;
    chromium*|chrome*) echo "" ;;
    brave*)     echo "󰖟" ;;
    mpv*)       echo "󰐹" ;;
    vlc*)       echo "󰕼" ;;
    *)          echo "" ;;
  esac
}

status_icon() {
  [[ "$1" == "Playing" ]] && echo "▶" || echo "⏸"
}

# Pick a player: prefer Playing, else Paused
pick_player() {
  local p st
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    st="$(playerctl -p "$p" status 2>/dev/null || true)"
    [[ "$st" == "Playing" ]] && { echo "$p"; return 0; }
  done < <(playerctl -l 2>/dev/null || true)

  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    st="$(playerctl -p "$p" status 2>/dev/null || true)"
    [[ "$st" == "Paused" ]] && { echo "$p"; return 0; }
  done < <(playerctl -l 2>/dev/null || true)

  return 1
}

PLAYER="$(pick_player 2>/dev/null || true)"

# ---- Nothing playing case ----
if [[ -z "$PLAYER" ]]; then
  case "$PART" in
    icon) echo "$fallback_icon" ;;
    text) echo "$fallback_text" ;;
    *)    echo "" ;;
  esac
  exit 0
fi

STATUS="$(playerctl -p "$PLAYER" status 2>/dev/null || true)"
ARTIST="$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || true)"
TITLE="$(playerctl -p "$PLAYER" metadata title 2>/dev/null || true)"

ARTIST="$(trim "$ARTIST")"
TITLE="$(trim "$TITLE")"

case "$PART" in
  player) echo "$PLAYER" ;;
  icon)   player_icon "$PLAYER" ;;
  status) status_icon "$STATUS" ;;
  text)
    if [[ -z "$TITLE" && -z "$ARTIST" ]]; then
      echo "$(status_icon "$STATUS") Now playing"
    elif [[ -z "$ARTIST" ]]; then
      echo "$(status_icon "$STATUS") $TITLE"
    else
      echo "$(status_icon "$STATUS") $TITLE — $ARTIST"
    fi
    ;;
  *) echo "" ;;
esac

