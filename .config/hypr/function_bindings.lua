-- Bindings for function row keys and custom keyboard keys

-- Volume controls
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { description = "Mute" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +5"), { description = "Raise Volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -5"), { description = "Lower Volume" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "Mute Mic" })

-- brightness controls
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +10"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -10"), { description = "Brightness Down" })

-- screenshot / prt sc
hl.bind("XF86Cut", hl.dsp.exec_cmd("cmd-screenshot"), { description = "Screenshot" })

-- custom side keys
hl.bind("XF86Launch1", hl.dsp.exec_cmd("menu"), { description = "Menu" }) -- The star key
hl.bind("XF86Launch2", hl.dsp.exec_cmd("launch-or-focus-tui wiremix"), { description = "Themes" }) -- Speaker settings key
hl.bind("XF86Launch3", hl.dsp.exec_cmd("toggle-nightlight"), { description = "Nightlight" }) -- The eye key
hl.bind("XF86Favorites", hl.dsp.exec_cmd("menu themes"), { description = "Themes" }) -- mode key

-- Other top keys
hl.bind("XF86RFKill", hl.dsp.exec_cmd("launch-or-focus-tui nmtui"), { description = "Wifi Config" })

-- Copilot key
hl.bind("XF86Assistant", hl.dsp.exec_cmd("launch-editor"), { locked = true }) -- copilot key
