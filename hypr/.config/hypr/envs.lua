-- Custom cursor theme (convertido do Windows "Cursor novo"), em ~/.icons/CursorNovo.
hl.env("XCURSOR_THEME", "CursorNovo")
hl.env("XCURSOR_SIZE", "24")

-- `env` só vale para processos iniciados depois; reaplica no compositor em si.
o.exec_on_start("hyprctl setcursor CursorNovo 24")
