pcall(require, "luarocks.loader")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

require("awful.autofocus")

-- Configurable stuff
modkey = "Mod1" -- 'Round these parts, we use left alt
terminal = "alacritty"
launcher = "launcher_colorful" -- A rofi thingy I have
background_dir = "$HOME/Pictures/backgrounds"
configdir = gears.filesystem.get_configuration_dir()

-- Autostarts
awful.spawn("picom") -- Compositor
awful.spawn("mpris-proxy") -- Proxy for headphone media control
awful.spawn("/usr/libexec/lxqt-policykit-agent") -- LXQt policykit
awful.spawn.with_shell(configdir .. "reverse_scroll.sh") -- I like MacOS scroll, ok?
awful.spawn.with_shell(configdir .. "vulkan.sh") -- Vulkan ICD file patching

-- Power menu widget
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")

-- Keybinds
globalkeys = gears.table.join(
	-- Main keys
	awful.key({modkey, "Shift"}, "e", function() logout_popup.launch() end,
		{description = "Quit awesome", group = "awesome"}),
	awful.key({modkey}, "Return", function() awful.spawn(terminal) end,
		{description = "Open a terminal", group = "launcher"}),
	awful.key({modkey}, "d", function() awful.spawn(launcher) end,
		{description = "Open a launcher", group = "launcher"}),
	awful.key({modkey, "Shift"}, "r", awesome.restart,
		{description = "Reload awesome", group = "awesome"}),
	
	-- Media keys
	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
		{description = "Raise the volume", group = "media"}),
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
		{description = "Lower the volume", group = "media"}),
	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
		{description = "Mute/unmute the speaker", group = "media"}),
	awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play") end,
		{description = "Play audio", group = "media"}),
	awful.key({}, "XF86AudioPause", function() awful.spawn("playerctl pause") end,
		{description = "Pause audio", group = "media"})
)

clientkeys = gears.table.join(
	awful.key({modkey, "Shift"}, "q", function(c) c:kill() end,
		{description = "Close a window", group = "client"}),
	awful.key({modkey, "Shift"}, "space", awful.client.floating.toggle,
		{description = "Toggle floating", group = "client"})
)

-- Stuff about tags
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View
		awful.key({modkey}, "#" .. i + 9, -- No idea how this works, honestly don't want to know
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{description = "View tag #"..i, group = "tag"}),
		-- Move to tag
		awful.key({modkey, "Shift"}, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
		{description = "Move to tag #"..i, group = "tag"})
	)
end

-- Tile by default, floating optional
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating
}

-- Base awful.rules.rules
awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys
		}
	},
	{
		rule = {class = "firefox"}, -- Firefox is different and not like the other girls
		properties = {maximized = false}
	},
}

desktop_rule = {
	rule_any = {
		name = {
			"pcmanfm-qt"
		}
	},
	properties = {
		focusable = false,
		sticky = true,
		keys = nil
	}
}

-- Append it to rules, maybe it will work idrk
table.insert(awful.rules.rules, desktop_rule)

-- Thingy for random background switching
globalkeys = gears.table.join(globalkeys,
	awful.key({modkey, "Shift"}, "b", function() awful.spawn.with_shell("pcmanfm-qt -w "..background_dir.."/$(ls "..background_dir.." | shuf -n 1);") end,
	{description = "Switch backgrounds", group = "desktop"})
)

root.keys(globalkeys)

-- pcmanfm-qt is used here
awful.spawn("pcmanfm-qt --desktop")

-- External files that would make this file way too large
require("taskbar")
require("signals")
