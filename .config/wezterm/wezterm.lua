-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "Nightfly (Gogh)"
-- config.color_scheme = "Sonokai (Gogh)"
config.color_scheme = "Catppuccin Macchiato (Gogh)"
config.font = wezterm.font({
	family = "FiraCode Nerd Font",
	weight = "Regular",
	style = "Normal",
	-- harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})
config.font_size = 22
config.window_background_opacity = 0.8
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.native_macos_fullscreen_mode = true
config.keys = {
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}

config.colors = {
	cursor_bg = "#f4dbd6",
}

-- This enable maximize window on startup
wezterm.on("gui-startup", function(cmd)
	-- Pick the active screen to maximize into, there are also other options, see the docs.
	local active = wezterm.gui.screens().active

	-- Set the window coords on spawn.
	local window = wezterm.mux.spawn_window(cmd or {
		x = active.x,
		y = active.y,
		width = active.width,
		height = active.height,
	})

	-- You probably don't need both, but you can also set the positions after spawn.
	window:gui_window():set_position(active.x, active.y)
	window:gui_window():set_inner_size(active.width, active.height)
end)

-- and finally, return the configuration to wezterm
return config
