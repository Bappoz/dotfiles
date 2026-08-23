-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 3,
    border_size = 0,
  },
})

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
})
