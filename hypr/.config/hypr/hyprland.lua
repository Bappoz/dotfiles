-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.envs")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Preserve explicitly pinned windows through dock minimization.
-- New browser windows keep their own tiled/floating state.
local MINIMIZED_PIN_TAG = "bappoz-minimized-pinned"

hl.on("window.move_to_workspace", function(window, workspace)
	local destination = workspace and workspace.name or ""
	local minimized = destination == "special:minimized"
	local restoring = not minimized and (tonumber(workspace and workspace.id) or 0) >= 1

	if minimized then
		if window.pinned then
			hl.dispatch(hl.dsp.window.tag({ tag = "+" .. MINIMIZED_PIN_TAG, window = window }))
		end
		if (window.fullscreen or 0) == 1 then
			hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset", window = window }))
		end
	elseif restoring then
		for _, tag in ipairs(window.tags or {}) do
			if tag == MINIMIZED_PIN_TAG or tag == MINIMIZED_PIN_TAG .. "*" then
				hl.timer(function()
					if not window.pinned then
						hl.dispatch(hl.dsp.window.pin({ window = window }))
					end
					hl.dispatch(hl.dsp.window.tag({ tag = "-" .. MINIMIZED_PIN_TAG, window = window }))
				end, { type = "oneshot", timeout = 2 })
			end
		end
	end
end)

-- Neutral frosted-glass titlebars and borders, independent of the active theme.
hl.config({
	general = {
		col = {
			active_border = {
				colors = { "rgba(ffffff70)", "rgba(8ad7ff66)", "rgba(caae4566)" },
				angle = 45,
			},
			inactive_border = "rgba(ffffff26)",
		},
	},
	plugin = {
		hyprbars = {
			bar_blur = true,
			bar_color = "rgba(ffffff1c)",
			inactive_button_color = "rgba(ffffff1c)",
			col = { text = "rgb(ffffff)" },
		},
	},
})

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Terminals open centered and floating; other applications keep their layout.
o.window({ tag = "terminal" }, {
  float = true,
  center = true,
  size = "((monitor_w*0.62)) ((monitor_h*0.62))",
})

-- zen-cal: painel de calendário flutuante (~/.local/bin/zen-cal-toggle).
o.window("^(TUI.zencal)$", {
	float = true,
	workspace = "current silent",
	move = "((monitor_w*0.375)) ((monitor_h*0.05))",
	size = "((monitor_w*0.25)) ((monitor_h*0.25))",
	opacity = 0.88,
})

-- Filee's experimental Wayland donut must float and be positioned at the cursor.
o.window({ title = "^Filee Donut$" }, {
	float = true,
	move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
})

do
	local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"
	local file = io.open(path, "r")
	if file then
		file:close()
		dofile(path)
	end
end

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
do local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end

-- Tiling by default; titlebars for windows explicitly floated with Super+T.
require("hypr.manual-floating")
