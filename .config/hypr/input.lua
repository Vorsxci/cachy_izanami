-- Control your input devices
-- See https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    -- kb_layout = "us,dk,eu",
    kb_layout = "us",
    kb_options = "compose:caps", -- ,grp:alts_toggle

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Start with numlock on by default
    numlock_by_default = true,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    -- sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      -- natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      -- clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.4,
    },
  },
  
  -- Gestures configuration block
  -- See https://wiki.hyprland.org/Configuring/Gestures/
  -- gestures = {
  --   workspace_swipe = true,
  -- },
})

-- Scroll nicely in the terminal (Window Rules)
hl.window_rule({
  name = "windowrule-1",
  match = { class = "(Alacritty|kitty)" },
  scroll_touchpad = 1.5,
})

hl.window_rule({
  name = "windowrule-2",
  match = { class = "com.mitchellh.ghostty" },
  scroll_touchpad = 0.2,
})
