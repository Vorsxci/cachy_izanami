-- Close windows
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("omarchy-cmd-close-all-windows"), { description = "Close all Windows" })

-- Control tiling
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind("SUPER + P", hl.dsp.window.pseudo({ action = "toggle" }), { description = "Pseudo window" })
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(
	"SHIFT + F11",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ description = "Force full screen" }
)
hl.bind(
	"ALT + F11",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ description = "Full width" }
)

-- Move focus with SUPER + arrow keys (Using exact l/r/u/d directions)
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }), { description = "Move focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }), { description = "Move focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }), { description = "Move focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }), { description = "Move focus down" })

-- Switch workspaces with SUPER + [0-9] (Unified under hl.dsp.focus)
hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = "1" }), { description = "Switch to workspace 1" })
hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = "2" }), { description = "Switch to workspace 2" })
hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = "3" }), { description = "Switch to workspace 3" })
hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = "4" }), { description = "Switch to workspace 4" })
hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = "5" }), { description = "Switch to workspace 5" })
hl.bind("SUPER + code:15", hl.dsp.focus({ workspace = "6" }), { description = "Switch to workspace 6" })
hl.bind("SUPER + code:16", hl.dsp.focus({ workspace = "7" }), { description = "Switch to workspace 7" })
hl.bind("SUPER + code:17", hl.dsp.focus({ workspace = "8" }), { description = "Switch to workspace 8" })
hl.bind("SUPER + code:18", hl.dsp.focus({ workspace = "9" }), { description = "Switch to workspace 9" })
hl.bind("SUPER + code:19", hl.dsp.focus({ workspace = "10" }), { description = "Switch to workspace 10" })
-- Move active window to a workspace with SUPER + SHIFT + [0-9]
hl.bind(
	"SUPER + SHIFT + code:10",
	hl.dsp.window.move({ workspace = "1" }),
	{ description = "Move window to workspace 1" }
)
hl.bind(
	"SUPER + SHIFT + code:11",
	hl.dsp.window.move({ workspace = "2" }),
	{ description = "Move window to workspace 2" }
)
hl.bind(
	"SUPER + SHIFT + code:12",
	hl.dsp.window.move({ workspace = "3" }),
	{ description = "Move window to workspace 3" }
)
hl.bind(
	"SUPER + SHIFT + code:13",
	hl.dsp.window.move({ workspace = "4" }),
	{ description = "Move window to workspace 4" }
)
hl.bind(
	"SUPER + SHIFT + code:14",
	hl.dsp.window.move({ workspace = "5" }),
	{ description = "Move window to workspace 5" }
)
hl.bind(
	"SUPER + SHIFT + code:15",
	hl.dsp.window.move({ workspace = "6" }),
	{ description = "Move window to workspace 6" }
)
hl.bind(
	"SUPER + SHIFT + code:16",
	hl.dsp.window.move({ workspace = "7" }),
	{ description = "Move window to workspace 7" }
)
hl.bind(
	"SUPER + SHIFT + code:17",
	hl.dsp.window.move({ workspace = "8" }),
	{ description = "Move window to workspace 8" }
)
hl.bind(
	"SUPER + SHIFT + code:18",
	hl.dsp.window.move({ workspace = "9" }),
	{ description = "Move window to workspace 9" }
)
hl.bind(
	"SUPER + SHIFT + code:19",
	hl.dsp.window.move({ workspace = "10" }),
	{ description = "Move window to workspace 10" }
)

-- Tab between workspaces (Unified under focus)
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind("SUPER + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
hl.bind("SUPER + SHIFT + left", hl.dsp.window.swap({ direction = "l" }), { description = "Swap window to the left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window to the right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- Cycle through applications on active workspace
hl.bind("ALT + TAB", hl.dsp.window.cycle_next(), { description = "Cycle to next window" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }), { description = "Cycle to prev window" })
hl.bind("ALT + TAB", hl.dsp.window.alter_zorder({ mode = "top" }), { description = "Reveal active window on top" })
hl.bind(
	"ALT + SHIFT + TAB",
	hl.dsp.window.alter_zorder({ mode = "top" }),
	{ description = "Reveal active window on top" }
)

-- Resize active window (Using structured x and y keys)
hl.bind("SUPER + code:20", hl.dsp.window.resize({ x = -100, y = 0 }), { description = "Expand window left" }) -- - key
hl.bind("SUPER + code:21", hl.dsp.window.resize({ x = 100, y = 0 }), { description = "Shrink window left" }) -- = key
hl.bind("SUPER + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100 }), { description = "Shrink window up" })
hl.bind("SUPER + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100 }), { description = "Expand window down" })

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll active workspace forward" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll active workspace backward" })
-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

hl.unbind("SUPER + W")
