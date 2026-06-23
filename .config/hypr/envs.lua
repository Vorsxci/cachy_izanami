-- Extra env variables
-- hl.env("MY_GLOBAL_ENV", "setting")
hl.env("XMODIFIERS", "@im=fcitx5")
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:/usr/local/bin:/usr/bin")
