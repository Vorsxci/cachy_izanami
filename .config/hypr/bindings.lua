-- Application bindings
local terminal = "uwsm app -- kitty"
local browser = "uwsm app -- chromium"
local fileapp = "uwsm app -- nautilus"

hl.bind("SUPER + return", hl.dsp.exec_cmd(terminal .. ' --dir="$(omarchy-cmd-terminal-cwd)"'), { description = "Terminal" })
hl.bind("SUPER + F", hl.dsp.exec_cmd(fileapp .. " --new-window"), { description = "File manager" })
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private"), { description = "Browser (private)" })
hl.bind("SUPER + M", hl.dsp.exec_cmd("launch-or-focus spotify"), { description = "Music" })
hl.bind("SUPER + N", hl.dsp.exec_cmd("launch-editor"), { description = "Editor" })
hl.bind("SUPER + T", hl.dsp.exec_cmd("launch-tui btop"), { description = "Activity" })
-- hl.bind("SUPER + D", hl.dsp.exec_cmd("omarchy-launch-tui discord"), { description = "Discord" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("gtk-launch line"), { description = "LINE" })
hl.bind("SUPER + O", hl.dsp.exec_cmd('launch-or-focus obsidian "uwsm app -- obsidian -disable-gpu --enable-wayland-ime"'), { description = "Obsidian" })
-- hl.bind("SUPER + slash", hl.dsp.exec_cmd("uwsm app -- 1password"), { description = "Passwords" })
hl.bind("SUPER + I", hl.dsp.exec_cmd("launch-hyprlock"), { description = "Hyprlock" })

-- If your web app url contains #, type it as ## to prevent hyperland treat it as comments
hl.bind("SUPER + A", hl.dsp.exec_cmd("launch-webapp 'https://chatgpt.com'"), { description = "ChatGPT" })
hl.bind("SUPER + C", hl.dsp.exec_cmd("launch-webapp 'https://app.hey.com/calendar/weeks/'"), { description = "Calendar" })
hl.bind("SUPER + Y", hl.dsp.exec_cmd("launch-or-focus-webapp YouTube 'https://youtube.com/'"), { description = "YouTube" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("launch-or-focus-webapp WhatsApp 'https://web.whatsapp.com/'"), { description = "WhatsApp" })
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("launch-or-focus-webapp 'Google Messages' 'https://messages.google.com/web/conversations'"), { description = "Google Messages" })
hl.bind("SUPER + D", hl.dsp.exec_cmd("launch-webapp 'https://discord.com/channels/@me'"), { description = "Discord" })

-- Overwrite existing bindings, like putting Omarchy Menu on Super + Space
-- hl.unbind("SUPER + SPACE")
-- hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("omarchy-menu"), { description = "Omarchy menu" })
hl.unbind("SUPER + ALT + SPACE") -- Basically fixed the issues with the menus by doing this for some reason (duplicate processes I think)
hl.unbind("SUPER + SPACE")
-- hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("omarchy-theme-bg-next"), { description = "Next" })
