.pragma library
var glyphs = {
 "󰐃":"pin", "󰒓":"settings", "󰅖":"x", "󰒟":"shuffle", "󰒮":"skip-back",
 "󰏤":"pause", "󰐊":"play", "󰒭":"skip-forward", "󰑖":"repeat", "󰕾":"volume-2",
 "󰅍":"copy", "󰈔":"file-text", "󰏌":"arrow-up-right", "󰇙":"ellipsis", "󰻃":"video",
 "󰓛":"power", "󰢌":"timer", "󰖔":"moon", "󰂛":"bell-off", "󰅶":"coffee",
 "󰆟":"scan-text", "󰌌":"keyboard", "󰚰":"refresh-cw", "󰋋":"headphones",
 "󰈀":"terminal", "󰈋":"sliders-horizontal", "󰄀":"camera", "󰏫":"pencil",
 "󰕌":"undo-2", "‹":"chevron-left", "›":"chevron-right", "+":"plus", "−":"minus", "♫":"music-2"
};
function resolve(value) { return glyphs[value] || ""; }
