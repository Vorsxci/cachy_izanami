#!/usr/bin/env bash
set -euo pipefail

line="$(bluetoothctl devices Connected 2>/dev/null | head -n1 || true)"
[[ -z "$line" ]] && exit 0

mac="$(awk '{print $2}' <<<"$line")"
name="${line#* $mac }"
[[ -z "$name" ]] && exit 0

# truncate for bar
max=18
if (( ${#name} > max )); then
  name="${name:0:max}…"
fi

printf "%s" "$name"

