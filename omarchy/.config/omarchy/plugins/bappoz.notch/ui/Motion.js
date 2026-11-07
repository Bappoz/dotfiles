.pragma library

// OpenNotchi macOS NotchAnimationStyle.swift + Windows styles.css, MIT.
var profiles = {
  fluid: {duration:380, curve:[0.32,1.25,0.45,1,1,1], scale:0.92, offset:-6, blur:4},
  bouncy: {duration:480, curve:[0.34,1.85,0.55,1,1,1], scale:0.72, offset:-20, blur:6},
  waterfall: {duration:460, curve:[0.22,1.28,0.36,1,1,1], scale:0.96, offset:-68, blur:6},
  snappy: {duration:140, curve:[0.16,1,0.3,1,1,1], scale:1, offset:0, blur:0},
  pop: {duration:460, curve:[0.4,1.95,0.5,0.95,1,1], scale:0.5, offset:0, blur:8},
  gentle: {duration:720, curve:[0.16,1,0.3,1,1,1], scale:0.96, offset:-8, blur:8},
  flip3D: {duration:540, curve:[0.34,1.35,0.55,1,1,1], scale:0.85, offset:0, blur:4, angle:-88, axisY:0, shade:0.70},
  depth3D: {duration:580, curve:[0.3,1.3,0.5,1,1,1], scale:0.38, offset:-28, blur:6, angle:-55, axisY:0, shade:0.85},
  cube3D: {duration:520, curve:[0.34,1.35,0.55,1,1,1], scale:0.70, offset:0, blur:4, angle:-95, axisY:0.4, shade:0.85}
};
var closingCurve = [0.32,0.72,0,1,1,1];
function profile(name) { return profiles[name] || profiles.fluid; }
function height(tab, mode) {
  if (tab === "home") return mode === "video" || mode === "lyrics" ? 294 : 200;
  if (tab === "agents") return 340;
  if (tab === "calendar") return 312;
  if (tab === "camera") return 460;
  if (tab === "settings") return 460;
  if (tab === "tools") return mode && mode !== "main" ? 410 : 264;
  return 200;
}
