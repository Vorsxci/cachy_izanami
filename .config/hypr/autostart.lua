-- exec-once = uwsm-app -- my-service
hl.on("hyprland.start", function()
	-- Greeter
	hl.exec_cmd("weather-update.sh")
	-- hl.exec_cmd("launch-hyprlock")

	-- "Services" start
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("spotify_player --daemon")
	hl.exec_cmd("systemctl --user start weather-update.timer")
	hl.exec_cmd(
		"uwsm app -- mpvpaper -o '--loop --no-audio --panscan=1.0 --hwdec=gpu' '*' ~/.config/themes/current/background"
	)
	hl.exec_cmd("fcitx5 -d")
	hl.exec_cmd("swayosd-server")
	hl.exec_cmd("~/.config/hypr/scripts/omarchy-animated-borders.sh")
	hl.exec_cmd("autopause-mpvpaper-whenclients.sh")
	hl.exec_cmd("wl-clip-persist --clipboard regular --all-mime-type-regex '^(?!x-kde-passwordManagerHint).+'")

	-- Start apps
	hl.exec_cmd("uwsm app -- quickshell")
	hl.exec_cmd("uwsm app -- elephant &")
	hl.exec_cmd("uwsm app -- walker --gapplication-service &")
	hl.exec_cmd("swayosd")
	hl.exec_cmd("swaync")

	hl.exec_cmd("notify.send 'Using CUSTOM autostart.conf'")
end)
