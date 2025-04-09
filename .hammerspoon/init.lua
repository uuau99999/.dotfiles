require("input-source")

hs.hotkey.bind({ "alt" }, "A", function()
	hs.application.launchOrFocus("Arc")
end)
hs.hotkey.bind({ "alt" }, "C", function()
	hs.application.launchOrFocus("Cursor")
end)
hs.hotkey.bind({ "alt" }, "I", function()
	hs.application.launchOrFocus("Ghostty")
end)
hs.hotkey.bind({ "alt" }, "W", function()
	hs.application.launchOrFocus("企业微信")
end)
hs.hotkey.bind({ "alt" }, "Q", function()
	hs.application.launchOrFocus("QQMusic")
end)
hs.hotkey.bind({ "alt" }, "N", function()
	hs.application.launchOrFocus("Notes")
end)
hs.hotkey.bind({ "alt" }, "S", function()
	hs.application.launchOrFocus("Spotify")
end)
hs.hotkey.bind({ "alt" }, "V", function()
	hs.application.launchOrFocus("Visual Studio Code")
end)
hs.hotkey.bind({ "alt" }, "D", function()
	hs.application.launchOrFocus("wechatwebdevtools.app")
end)

local function resizeApp()
	-- send keyStroke to raycast to resize it.
	hs.eventtap.keyStroke({ "alt" }, "m")
end

local function applicationWatcher(appName, eventType)
	if eventType == hs.application.watcher.launched then
		resizeApp()
	end
	if eventType == hs.application.watcher.activated and appName == "Preview" then
		resizeApp()
	end
end

appResizeWatcher = hs.application.watcher.new(applicationWatcher)
appResizeWatcher:start()

local function reloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
