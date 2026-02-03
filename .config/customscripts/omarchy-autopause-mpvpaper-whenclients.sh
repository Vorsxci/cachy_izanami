#!/bin/bash
echo "[INFO] Waiting for Hyprland to be ready..."
until hyprctl -j monitors >/dev/null 2>&1; do
    sleep 0.5
done
echo "[INFO] Hyprland is ready. Starting autopause watcher..."

check_active_workspace() {
    local active_ws=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    local count=$(hyprctl -j clients | jq "[.[] | select(.workspace.id == $active_ws)] | length")

    if [ "$count" -eq 0 ]; then
       # echo "[INFO] Workspace $active_ws is empty → resuming mpvpaper"
        pkill -CONT -x mpvpaper
    else
       # echo "[INFO] Workspace $active_ws has $count windows → pausing mpvpaper"
        pkill -STOP -x mpvpaper
    fi
}

# echo "[INFO] Starting mpvpaper pause/resume watcher..."
# echo "[INFO] Subscribing to Hyprland events (openwindow, closewindow, activeworkspace)"

while true; do
hyprctl -j subscribe '["openwindow","closewindow","activeworkspace"]' | \
while read -r line; do
     echo "[DEBUG] Got event: $line"
    # Tiny delay → ensures Hyprland updates client list before we query
    sleep 1
    check_active_workspace
done
sleep 1
done
