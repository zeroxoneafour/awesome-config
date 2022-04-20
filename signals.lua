-- Idk how signals work so here's some code I copied from the default rc.lua

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- Titlebars
client.connect_signal("request::titlebars", function(c)
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", {raise=true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", {raise=true})
			awful.mouse.client.resize(c)
		end)
	)

	local icon = wibox.container.margin()
	icon:set_margins(2)
	icon:set_widget(awful.titlebar.widget.iconwidget(c))

	local tb = awful.titlebar(c, {
		height = 16
	}) : setup {
		{ -- Left
			icon,
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.minimizebutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	}
end)

client.connect_signal("property::floating", function(c)
	if c.floating then
		if c.titlebar == nil then
			c:emit_signal("request::titlebars", "rules", {})
		end
	awful.titlebar.show(c)
	else
		awful.titlebar.hide(c)
	end
end)

client.connect_signal("manage", function(c) 
	if c.first_tag.layout == awful.layout.suit.floating then
		c.floating = true
		c:emit_signal("property::floating", "rules", {})
	end
end)

-- Focus follows mouse
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Update border color when focused
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
