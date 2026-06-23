-- --- Global float normalization (from forum pattern) ---
hl.window_rule({ match = { float = true }, fullscreen_state = "0 0" })
hl.window_rule({ match = { float = true }, maximize = false })
hl.window_rule({ match = { float = true }, fullscreen = false })
hl.window_rule({ match = { float = true }, suppress_event = "maximize" })
hl.window_rule({ match = { float = true }, suppress_event = "fullscreen" })
hl.window_rule({ match = { float = true }, center = true })
hl.window_rule({ match = { float = true }, size = "60% 70%" })

-- --- menu TUIs: force float by app-id ---
hl.window_rule({ match = { class = "^(org%.cachy%.tui)$" }, float = true })
hl.window_rule({ match = { class = "^(org%.cachy%.tui)$" }, size = "750 550" })
hl.window_rule({ match = { class = "^(org%.cachy%.present)$" }, float = true })
hl.window_rule({ match = { class = "^(org%.cachy%.editor)$" }, float = true })
hl.window_rule({ match = { class = "^(org%.cachy%.editor)$" }, size = "750 550" })

-- Optional: give “present” a slightly bigger default
hl.window_rule({ match = { class = "^(org%.cachy%.present)$" }, size = "70% 75%" })
hl.window_rule({ match = { class = "^(org%.cachy%.present)$" }, center = true })

-- Fixed typo from "widowrule" -> "hl.window_rule" for fallback scripts
hl.window_rule({ match = { class = "^(org%.cachy%.*)$" }, float = true })
hl.window_rule({ match = { class = "^(org%.cachy%.*)$" }, center = true })

-- For any apps specifically
hl.window_rule({ match = { class = "^(com%.gabm%.satty)$" }, float = true })
hl.window_rule({ match = { class = "^(com%.gabm%.satty)$" }, center = true })

hl.window_rule({
  name = "cachy-catchall",
  match = { class = "^(org%.cachy%.)" },
  float = true,
  center = true,
  size = "1050 650",
})

hl.window_rule({
  name = "quickshell-run-widget",
  match = { class = "^(quickshell-run)$" },
  float = true,
  no_blur = true,
  border_size = 0,
  no_shadow = true,
  rounding = 0,
  pin = true,
  suppress_event = "fullscreen",
})

-- Rules for the quickshell run widget terminal 
-- (Combined your two quickshell terminal sections to avoid conflicting size/center toggles)
hl.window_rule({
  name = "quickshell-terminal",
  match = { class = "^(quickshell%.run%.terminal)$" },
  float = true,
  pin = true,
  no_blur = true,
  center = false,
  size = "350 300",
  move = "10 300",
  no_anim = true,
})

-- --- Silent spotify ---
hl.window_rule({ match = { class = "^(Spotify)$" }, workspace = "99 silent" })
