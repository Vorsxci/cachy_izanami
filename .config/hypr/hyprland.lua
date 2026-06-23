-- Learn how to configure Hyprland: https://wiki.hyprland.org/Configuring/

-- Use defaults Omarchy defaults (Absolute path outside of the hypr folder)
--dofile(os.getenv("HOME") .. "/.config/themes/current/hyprland.lua")

-- Change your own setup in these files (Sourced relative to ~/.config/hypr/)
require("monitors")
require("input")
require("bindings")
require("envs")
require("looknfeel")
require("autostart")
require("rules")

-- Below currently manages all custom stuff and starts
require("custom_tiling")
require("custom_utilities")
require("custom_windows")
require("function_bindings")
-- require("apps/some_app")

-- Core Misc Settings
hl.config({
	misc = {
		allow_session_lock_restore = true,
	},
})
