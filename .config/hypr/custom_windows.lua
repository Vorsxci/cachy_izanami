-- --- Weather config popup (force floating)
hl.window_rule({
  name = "windowrule-1",
  match = { class = "^(omarchy-weathercfg)$" },
  float = true,
  size = { 520, 420 },
  center = true,
  pin = true,
  border_size = 0,
})
