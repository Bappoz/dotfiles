-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 3,
		border_size = 1,
	},
})

hl.layer_rule({ match = { namespace = "^launchpad$" }, blur = true, ignore_alpha = 0.2 })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		-- Use round window corners.
		rounding = 8,

		-- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
		dim_inactive = true,
		dim_strength = 0.1,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
	misc = {
		-- Restore the session lock screen after a compositor crash/restart.
		allow_session_lock_restore = true,
	},
	cursor = {
		-- Keep the pointer visible while typing.
		hide_on_key_press = false,
	},
})

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
	decoration = {
		dim_strength = 0.06,
		rounding = 8,

		blur = {
			contrast = 0,
			enabled = true,
			popups = false,
			size = 12,
		},

		glow = {
			enabled = false,
			range = 0,
			render_power = 4,
		},
	},

	dwindle = {
		force_split = 2,
		smart_split = false,
	},

	general = {
		border_size = 1,
		float_gaps = 0,
	},
})
-- <<< omaland managed block <<<

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.

-- Notchi uses its own shape animation; Hyprland supplies the glass blur.
hl.layer_rule({
  match = { namespace = "^bappoz-notch$" },
  blur = true,
  ignore_alpha = 0.05,
  no_anim = true,
})

-- Frosted glass for the dock overlay.
hl.layer_rule({ match = { namespace = "^omarchy-dock$" }, blur = true, ignore_alpha = 0.05 })
