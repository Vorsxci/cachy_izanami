-- 1. Register the endless linear loop curve globally
hl.curve("endless", { type = "bezier", points = { {0.5, 0.5}, {0.5, 0.5} } })

-- 2. Hook borderangle into the hardware loop
hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 100, -- Keeps it at your nice matching slower rotation speed
	bezier = "endless",
	style = "loop",
})

-- 3. Pass your warm/fiery theme configuration block
hl.config({
	general = {
		["col.active_border"] = {
			colors = {
				"rgba(ff9898ff)",
				"rgba(ff6557ff)",
				"rgba(ffca98ff)",
				"rgba(ff6557ff)", -- Symmetrical mirror point
				"rgba(ff9898ff)", -- Perfect loop wrap point
			},
			angle = 45,
		},
		["col.inactive_border"] = {
			colors = { "rgba(4f3506ff)", "rgba(4f0806ff)" },
			angle = 45,
		},
		border_size = 4,
	},

	decoration = {
		rounding = 8,

		shadow = {
			enabled = true,
			range = 5,
			render_power = 3,
			color = "rgba(ff6c5cff)",
			color_inactive = "rgba(00000055)",
		},
	},
})
