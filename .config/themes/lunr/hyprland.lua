hl.curve("endless", { type = "bezier", points = { { 0.5, 0.5 }, { 0.5, 0.5 } } })

-- 1. Hook borderangle into the absolute native hardware default curve
hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 100, -- 30 ds = 3 seconds per complete 360° rotation loop
	bezier = "endless", -- Bypasses manual curve evaluations to prevent stalls
	style = "loop",
})

-- 2. Pass the symmetrical array block
hl.config({
	general = {
		["col.active_border"] = {
			colors = {
				"rgba(605a80ff)",
				"rgba(afc5daff)",
				"rgba(fefbd0ff)",
				"rgba(afc5daff)",
				"rgba(605a80ff)",
			},
			angle = 45,
		},
		["col.inactive_border"] = {
			colors = { "rgba(637794ff)", "rgba(3e4a5bff)" },
			angle = 45,
		},
		border_size = 4,
	},

	decoration = {
		rounding = 8,

		shadow = {
			enabled = true,
			range = 10,
			render_power = 3,
			color = "rgba(afc5daff)",
			color_inactive = "rgba(00000055)",
		},
	},
})
