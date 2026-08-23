-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- US + ABNT2, alterna com Alt + Shift.
    kb_layout = "us,br",
    kb_variant = "",
    kb_options = "grp:alt_shift_toggle",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 600,

    -- Start with numlock on by default.
    numlock_by_default = true,

    -- Increase sensitivity for mouse/trackpad (default: 0).
    sensitivity = -0.15,
    scroll_factor = 0.5,

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.5,

      -- Enable the touchpad while typing.
      disable_while_typing = false,
    },
  },
})

-- App-specific touchpad scroll speeds.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Teclado externo (Microdia 2.4G Dongle, 0c45:fdfd) ficou preso em modo Mac e
-- manda os scancodes de Alt e Super trocados; o toggle Fn do firmware nao
-- reverte. Desfaz a troca so nesse dispositivo.
for _, dev in ipairs({ "2.4g-dongle", "2.4g-dongle-keyboard" }) do
  hl.device({
    name = dev,
    kb_layout = "us,br",
    kb_variant = "",
    kb_options = "grp:alt_shift_toggle,altwin:swap_lalt_lwin",
  })
end
