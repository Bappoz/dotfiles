-- User-owned titlebars, independent of floating workspace mode.
local paths = require("default.hypr.paths")
local WORKSPACE_TAG = "bappoz-manual-floating"
local TITLEBARS = "/usr/lib/omarchy-hyprland-titlebars/titlebars.so"
local function theme_colors()
  local colors = {}
  -- omarchy-theme-set writes the current theme under ~/.local/state whatever
  -- XDG_STATE_HOME says, and Hyprland loads the theme's own config from there.
  local file = io.open(paths.home .. "/.local/state/omarchy/current/theme/colors.toml", "r")

  if file then
    for line in file:lines() do
      local key, value = line:match('^%s*([%w_]+)%s*=%s*"#(%x%x%x%x%x%x)"')
      if key then
        colors[key] = "rgb(" .. value .. ")"
      end
    end

    file:close()
  end

  local background = colors.background or "rgb(1a1b26)"
  -- A titlebar in the window's own background color runs into the window, so it
  -- takes the theme's raised surface. Themes that make that the background too
  -- fall back to their selection color.
  local titlebar = colors.lighter_background
  if not titlebar or titlebar == background then
    titlebar = colors.selection or background
  end

  return {
    background = background,
    foreground = colors.foreground or "rgb(c0caf5)",
    titlebar = titlebar,
  }
end

-- Titlebars come from omarchy-hyprland-titlebars, loaded once something floats.
-- The plugin reloads the config once it is in, which is the pass that finds its
-- options here. Its options reset on every load, so it draws nothing until enabled.
local function titlebars_installed()
  local file = io.open(TITLEBARS, "r")
  if not file then
    return false
  end
  file:close()
  return true
end

local function titlebars()
  if not titlebars_installed() then
    return
  end

  hl.plugin.load(TITLEBARS)

  if not hl.plugin.hyprbars then
    return
  end

  local colors = theme_colors()
  local window = [[window = "address:%WINDOW%"]]

  hl.config({
    plugin = {
      hyprbars = {
        enabled = true,
        workspace_tag = WORKSPACE_TAG,
        bar_height = 34,
        bar_color = colors.titlebar,
        col = { text = colors.foreground },
        bar_text_font = "sans-serif",
        bar_text_size = 12,
        bar_text_weight = "normal",
        bar_text_align = "center",
        bar_buttons_alignment = "right",
        bar_part_of_window = true,
        bar_precedence_over_border = true,
        bar_padding = 12,
        bar_button_padding = 8,
        button_rounding = -1,
        icon_on_hover = true,
        inactive_button_color = "rgba(00000000)",
        on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " .. window .. " })'",
      },
    },
  })

  for _, button in ipairs({
    { color = "rgb(ff5f57)", icon = "×", action = "hyprctl dispatch 'hl.dsp.window.close({ " .. window .. " })'" },
    { color = "rgb(28c840)", icon = "⤢", action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " .. window .. " })'" },
    -- Minimized windows wait in the dock, which brings them back.
    { color = "rgb(febc2e)", icon = "−", action = "/home/bappoz/.local/bin/bappoz-window-minimize %WINDOW%" },
  }) do
    hl.plugin.hyprbars.add_button({
      bg_color = button.color,
      fg_color = "rgba(00000099)",
      size = 13,
      icon = button.icon,
      action = button.action,
    })
  end
end


titlebars()
hl.config({ plugin = { hyprbars = {
  bar_blur = true, bar_color = "rgba(dde7f530)",
  bar_color_inactive = "rgba(dde7f520)",
  inactive_button_color = "rgba(00000000)", col = { text = "rgb(ffffff)" },
} } })

function o.manual_float_toggle()
  local window = hl.get_active_window()
  if not window then return end
  local floating = not window.floating
  hl.dispatch(hl.dsp.window.tag({ tag = (floating and "+" or "-") .. WORKSPACE_TAG, window = window }))
  hl.dispatch(hl.dsp.window.float({ action = floating and "on" or "off", window = window }))
end
o.rebind("SUPER + T", "Toggle window floating/tiling", o.manual_float_toggle)
o.rebind("SUPER + M", "Minimize window to the dock", "/home/bappoz/.local/bin/bappoz-window-minimize")

-- Neutral glass edge, with the colored controls confined to the titlebar.
hl.config({
  general = { col = {
    active_border = "rgba(ffffff65)",
    inactive_border = "rgba(ffffff28)",
  } },
  decoration = { blur = { enabled = true, size = 8, passes = 2, contrast = 1.0, brightness = 1.0 } },
})

-- Give newly opened terminals the same titlebar as manually floated windows.
hl.on("window.open", function(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag == "terminal" or tag == "terminal*" then
      hl.dispatch(hl.dsp.window.tag({ tag = "+" .. WORKSPACE_TAG, window = window }))
      break
    end
  end
end)
