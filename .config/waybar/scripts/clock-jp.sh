#!/usr/bin/env bash

case $(date +%u) in
  1) d="月曜日" ;;
  2) d="火曜日" ;;
  3) d="水曜日" ;;
  4) d="木曜日" ;;
  5) d="金曜日" ;;
  6) d="土曜日" ;;
  7) d="日曜日" ;;
esac

printf "%s %s\n" "$d" "$(date +%H:%M)"

