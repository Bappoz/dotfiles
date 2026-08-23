-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- SUPER+SHIFT+W é Omawrite no default do Quattro.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- SUPER+ALT+RETURN abre com Herdr em vez do Tmux default.
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + ALT + RETURN", "Terminal (Herdr)", { omarchy = "terminal-herdr" })
