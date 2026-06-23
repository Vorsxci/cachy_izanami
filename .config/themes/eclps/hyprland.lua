-- 1. Register the endless linear loop curve globally
hl.curve("endless", { type = "bezier", points = { {0.5, 0.5}, {0.5, 0.5} } })

-- 2. Hook borderangle into the hardware loop
hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 100,
	bezier = "endless",
	style = "loop",
})

-- 3. Pass your minimalist ash/gold theme configuration block
hl.config({
	general = {
		["col.active_border"] = {
			colors = {
				"rgba(22252eff)",
				"rgba(f2d38aff)",
				"rgba(22252eff)",
				"rgba(f2d38aff)", -- Symmetrical mirror point
				"rgba(22252eff)", -- Perfect loop wrap point
			},
			angle = 45,
		},
		["col.inactive_border"] = {
			colors = { "rgba(12141aff)", "rgba(181b22ff)" },
			angle = 45,
		},
		border_size = 3,
	},

	decoration = {
		rounding = 8,
		-- Modern Lua syntax for rounding_power property
		["rounding_power"] = 1,

		shadow = {
			enabled = true,
			range = 6,
			render_power = 3,
			color = "rgba(7b6c9d33)",
			color_inactive = "rgba(00000055)",
		},
	},
})

