local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- Widgets
local assault = require("assault")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local net_widgets = require("net_widgets")

-- Make tag list buttons
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t) t:view_only() end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			-- idk
			c:emit_signal(
				"request::activate",
				"tasklist",
				{raise = true, minimized = false}
			)
		end
	end)
)

-- Big boi function for small taskbar
local function taskbar(screen)

	-- Set bar height here so it can be updated across certain other stuff
	local bar_height = dpi(32)

	-- Tags I guess, I have no idea whats going on
	awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, screen, awful.layout.layouts[1])

	-- How does this link together
	screen.taglist = awful.widget.taglist {
		screen = screen,
		filter = awful.widget.taglist.filter.noempty,
		buttons = taglist_buttons
	}
	screen.tasklist = awful.widget.tasklist {
		screen = screen,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			spacing_widget = {
				{
					forced_width  = 5,
					forced_height = bar_height/2,
					thickness = 1,
					color = "#777777",
					widget = wibox.widget.separator
				},
				valign = "center",
				halign = "center",
				widget = wibox.container.place,
			},
			spacing = 1,
			layout = wibox.layout.fixed.horizontal
		},
    -- Notice that there is *NO* wibox.wibox prefix, it is a template,
    -- not a widget instance.
		widget_template = {
			{
				wibox.widget.base.make_widget(),
				id = "background_role",
				widget = wibox.container.background,
			},
			{
				{
					id = "clienticon",
					widget = awful.widget.clienticon,
				},
				margins = bar_height/8,
				widget = wibox.container.margin
			},
			nil,
			create_callback = function(self, c, index, objects) --luacheck: no unused args
				self:get_children_by_id("clienticon")[1].client = c
			end,
			layout = wibox.layout.stack,
		},
	}

	screen.textclock = wibox.widget.textclock("%l:%M:%S %p, %A %B %e %Y", 1)
	local cw = calendar_widget({placement = "bottom_right", start_sunday=true, theme="light"})
	screen.textclock:connect_signal("button::press", function(_,_,_, button) if button == 1 then cw.toggle() end end)

	local tray = wibox.layout.fixed.horizontal()
	tray:setup {
		spacing = bar_height/4,
		layout = wibox.layout.fixed.horizontal,
		wibox.widget.systray(),
		volume_widget{widget_type = "icon", device = "default", mixer_cmd = "pavucontrol-qt", main_color = beautiful.fg_normal},
		assault({width = 24, height = 16}),
		net_widgets.wireless({interface="wlo1",popup_position="bottom_right"}),
		screen.textclock
	}

	local tray_margin = wibox.layout.margin()
	tray_margin:set_margins(bar_height/4)
	tray_margin:set_widget(tray)

	-- help me please
	screen.wibox = awful.wibar({ position = "bottom", screen = screen, height = bar_height })

	screen.wibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left side
			layout = wibox.layout.fixed.horizontal,
			screen.taglist,
		},
		-- Task list
		screen.tasklist,
		-- Tray
		tray_margin
	}
end

awful.screen.connect_for_each_screen(taskbar)
