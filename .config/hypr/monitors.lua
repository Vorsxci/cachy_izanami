-- See https://wiki.hyprland.org/Configuring/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors
-- You must relaunch Hyprland after changing any envs (use Super+Esc, then Relaunch)

-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
hl.env("GDK_SCALE", "2")

hl.config({
  monitor = {
    {
      name = "eDP-1",
      res = "preferred",
      pos = "2880x1800@144",
      scale = "auto",
    },
    -- External displays:
    {
      name = "DP-1",
      res = "preferred",
      pos = "auto",
      scale = 2,
      mirror = "eDP-1",
    },
    -- {
    --   name = "DP-1",
    --   res = "preferred",
    --   pos = "auto",
    --   scale = "auto",
    -- },
  },
})

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
-- hl.env("GDK_SCALE", "1.75")
-- hl.config({ monitor = {{ name = "", res = "preferred", pos = "auto", scale = 1.666667 }} })

-- Straight 1x setup for low-resolution displays like 1080p or 1440p
-- hl.env("GDK_SCALE", "1")
-- hl.config({ monitor = {{ name = "", res = "preferred", pos = "auto", scale = 1 }} })

-- Example for Framework 13 w/ 6K XDR Apple display
-- hl.config({
--   monitor = {
--     { name = "DP-5", res = "6016x3384@60", pos = "auto", scale = 2 },
--     { name = "eDP-1", res = "2880x1920@120", pos = "auto", scale = 2 },
--   }
-- })
