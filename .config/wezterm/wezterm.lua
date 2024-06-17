-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "Nightfly (Gogh)"
-- config.color_scheme = "Sonokai (Gogh)"
config.color_scheme = "Oxocarbon Dark (Gogh)"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 18
config.window_background_opacity = 0.9
config.macos_window_background_blur = 10
config.window_decorations = "RESIZE"
config.colors = {
	-- cursor_bg = "#a5e179",
}

-- and finally, return the configuration to wezterm
return config
