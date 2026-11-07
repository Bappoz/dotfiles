-- BEGIN hyprmoncfg wake settings
-- Shared with Omarchy while hyprmoncfg manages displays.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
-- END hyprmoncfg wake settings
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Fallback for any monitor not listed below.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- HDMI-A-1 (externo, AOC) à esquerda; eDP-1 (notebook, principal) à direita.
-- eDP-1 ancorado em 0x0 e o externo em x negativo: o share picker do
-- xdg-desktop-portal-hyprland recorta thumbnails de output fora do viewport,
-- então a tela interna sozinha num offset positivo some da aba "Outputs"
-- ao compartilhar tela.
hl.monitor({ output = "eDP-1", mode = "1366x768@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "-1920x0", scale = 1 })
