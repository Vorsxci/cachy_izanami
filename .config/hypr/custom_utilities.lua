-- Menus
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd('walker -p "Start…"'), { description = "Launch apps" })
hl.bind("SUPER + CTRL + E", hl.dsp.exec_cmd("walker -m Emojis"), { description = "Emoji picker" })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("menu"), { description = "Menu" })
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("menu system"), { description = "Power menu" })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("menu system"), { locked = true, description = "Power menu" })
hl.bind("SUPER + K", hl.dsp.exec_cmd("menu-keybindings"), { description = "Show key bindings" })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"), { description = "Calculator" })

-- Aesthetics
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("toggle-waybar"), { description = "Toggle top bar" })
hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("/home/kazuki/.local/bin/theme-bg-next"), { description = "Next background in theme" })
hl.bind("SUPER + SHIFT + CTRL + SPACE", hl.dsp.exec_cmd("menu themes"), { description = "Pick new theme" })
hl.bind("SUPER + BACKSPACE", hl.dsp.exec_cmd([[hyprctl dispatch setprop "address:$(hyprctl activewindow -j | jq -r '.address')" opaque toggle]]), { description = "Toggle window transparency" })

-- Notifications
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("makoctl dismiss"), { description = "Dismiss last notification" })
hl.bind("SUPER + SHIFT + COMMA", hl.dsp.exec_cmd("makoctl dismiss --all"), { description = "Dismiss all notifications" })
hl.bind("SUPER + CTRL + COMMA", hl.dsp.exec_cmd([[makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send "Silenced notifications" || notify-send "Enabled notifications"]]), { description = "Toggle silencing notifications" })

-- Toggle idling
hl.bind("SUPER + CTRL + I", hl.dsp.exec_cmd("toggle-idle"), { description = "Toggle locking on idle" })

-- Toggle nightlight
hl.bind("SUPER + CTRL + N", hl.dsp.exec_cmd("toggle-nightlight"), { description = "Toggle nightlight" })

-- Control Apple Display brightness
hl.bind("CTRL + F1", hl.dsp.exec_cmd("omarchy-cmd-apple-display-brightness -5000"), { description = "Apple Display brightness down" })
hl.bind("CTRL + F2", hl.dsp.exec_cmd("omarchy-cmd-apple-display-brightness +5000"), { description = "Apple Display brightness up" })
hl.bind("SHIFT + CTRL + F2", hl.dsp.exec_cmd("omarchy-cmd-apple-display-brightness +60000"), { description = "Apple Display full brightness" })

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("cmd-screenshot region"), { description = "Screenshot of region" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("cmd-screenshot window"), { description = "Screenshot of window" })
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("cmd-screenshot output"), { description = "Screenshot of display" })

-- Screen recordings
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("cmd-screenrecord region"), { description = "Screen record a region" })
hl.bind("ALT + SHIFT + PRINT", hl.dsp.exec_cmd("cmd-screenrecord region audio"), { description = "Screen record a region with audio" })
hl.bind("CTRL + ALT + PRINT", hl.dsp.exec_cmd("cmd-screenrecord output"), { description = "Screen record display" })
hl.bind("CTRL + ALT + SHIFT + PRINT", hl.dsp.exec_cmd("cmd-screenrecord output audio"), { description = "Screen record display with audio" })

-- Color picker
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a"), { description = "Color picker" })

-- File sharing
hl.bind("CTRL + SUPER + S", hl.dsp.exec_cmd("menu share"), { description = "Share" })
