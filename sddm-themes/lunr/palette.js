// =============================================================
// palette.js — LuNR OS color palette
// Sourced by all QML components. Swap this file per theme.
// =============================================================
// Color provenance:
//   #FEFBD0  softyellow  — moon glow
//   #D8DEE9  doveblue    — soft neutral text
//   #AFC5DA  mutedblue   — cool blue accent
//   #B48EAD  lilac       — soft purple accent
//   #605A80  mutedviolet — deep violet (glass tint)
//   #2E3440  base        — dark panel background
.pragma library

// ── Core text ─────────────────────────────────────────────────
var textPrimary   = "#FEFBD0"        // softyellow — moon glow
var textDim       = "#D8DEE9"        // doveblue — softer body text
var textAlt       = "#AFC5DA"        // mutedblue — cool blue labels

// ── Backgrounds / glass ───────────────────────────────────────
var glass         = "#44605A80"      // mutedviolet glass tint
var glassBright   = "#66605A80"      // mutedviolet hovered
var fieldBg       = "#CC2E3440"      // base — dark input field
var imageBacking  = "#F02E3440"      // base — deep backing
var panelBg       = "#EE2E3440"      // base — panel background

// ── Accents ───────────────────────────────────────────────────
var accent        = "#FAFF99"        // selected-text — bright yellow-lime highlight
var accentGlow    = "#55FAFF99"      // accent glow (alpha 0x55)
var accentAlt     = "#B48EAD"        // lilac — secondary accent
var barFill       = "#FEFBD0"        // softyellow — bar fill
var checkColor    = "#AFC5DA"        // mutedblue — success / auth ok
var errorColor    = "#D26450"        // error red (unchanged)

// ── Borders ───────────────────────────────────────────────────
var border1       = "#33FEFBD0"      // softyellow border, subtle
var border2       = "#22AFC5DA"      // mutedblue border, subtle

// ── Hover / selection ─────────────────────────────────────────
var hoverBg       = "#44B48EAD"      // lilac hover background
var hoverBorder   = "#CCB48EAD"      // lilac hover border
var selectedBg    = "#55605A80"      // mutedviolet selected background
var selectedBorder= "#CCAFC5DA"      // mutedblue selected border

// ── Gradient stops (for future use in shaders / decorations) ──
var grad1         = "#FEFBD0"        // softyellow
var grad2         = "#D8DEE9"        // doveblue
var grad3         = "#AFC5DA"        // mutedblue
var grad4         = "#B48EAD"        // lilac
var grad5         = "#D8DEE9"        // doveblue

// ── Typography ────────────────────────────────────────────────
var fontFamily    = "Google Sans Display"
var fontFamilyMono= "JetBrains Mono"

// ── Paths ─────────────────────────────────────────────────────
var backgroundImage = "/usr/share/sddm/themes/lunr/assets/background.png"
var logoImage       = "/usr/share/sddm/themes/lunr/assets/logo.png"

// ── Scripts ───────────────────────────────────────────────────
var scriptWeather    = "/home/kazuki/.config/weather/weather-read.sh"
var scriptNowPlaying = "/home/kazuki/.config/hypr/scripts/lock-nowplaying.sh"
var scriptBattery    = "/home/kazuki/.config/hypr/scripts/lock-battery.sh"

// ── Power scripts ─────────────────────────────────────────────
var scriptPowerOff   = "/home/kazuki/.local/bin/cmd-shutdown"
var scriptReboot     = "/home/kazuki/.local/bin/cmd-reboot"
