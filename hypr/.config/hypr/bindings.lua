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
o.bind("SUPER + A", "Spotlight Apps", "omarchy-shell shell toggle io.github.jeocrypto.launchpad")

-- Workspace numbers identify one workspace across every monitor. Focusing an
-- existing workspace follows it; it never moves the workspace to this screen.
-- Omarchy's per-monitor reconciler would otherwise relocate these workspaces
-- on config reload or when a monitor is connected.
o.workspaces.reconcile = function() end

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.rebind("SUPER + " .. key, "Focus workspace " .. workspace,
    hl.dsp.focus({ workspace = tostring(workspace), on_current_monitor = false }))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end

-- Notchi: a separate shortcut; Super+Ctrl+N keeps opening Network.
o.bind("SUPER + ALT + N", "Notchi", "omarchy-shell bappoz.notch toggle")

-- Explicit workspace moves keep their global number on the destination screen.
for _, direction in ipairs({ {"LEFT", "l"}, {"RIGHT", "r"}, {"UP", "u"}, {"DOWN", "d"} }) do
  o.rebind("SUPER + SHIFT + ALT + " .. direction[1], "Move workspace to " .. direction[2] .. " monitor",
    hl.dsp.workspace.move({ monitor = direction[2] }))
end
