// =============================================================
// palette.js — SOLR OS color palette
// Sourced by all QML components. Swap this file per theme.
// =============================================================
// Color provenance:
//   #FFDCA0  peach       — solar glow / primary text
//   #D8DEE9  doveblue    — soft neutral text (nord neutral)
//   #FF9898  pink        — warm rose accent
//   #FF6557  redorange   — solar flare / selected
//   #F4A340  orange      — corona orange accent
//   #ffca98  grad1       — pale amber gradient
//   #2E3440  base        — dark panel background (nord)
.pragma library

// ── Core text ─────────────────────────────────────────────────
var textPrimary   = "#FFDCA0"        // peach — solar glow
var textDim       = "#D8DEE9"        // doveblue — softer body text
var textAlt       = "#FF9898"        // pink — warm rose labels

// ── Backgrounds / glass ───────────────────────────────────────
var glass         = "#44332B1A"      // warm amber-tinted dark glass
var glassBright   = "#66433520"      // warmer hovered glass
var fieldBg       = "#CC2E3440"      // base — dark input field
var imageBacking  = "#F02E3440"      // base — deep backing
var panelBg       = "#EE2E3440"      // base — panel background

// ── Accents ───────────────────────────────────────────────────
var accent        = "#FF6557"        // redorange — solar flare highlight
var accentGlow    = "#55FF6557"      // accent glow (alpha 0x55)
var accentAlt     = "#FF9898"        // pink — secondary accent
var barFill       = "#F4A340"        // orange — bar fill
var checkColor    = "#FFDCA0"        // peach — success / auth ok
var errorColor    = "#FF6557"        // solar flare red

// ── Borders ───────────────────────────────────────────────────
var border1       = "#33FFDCA0"      // peach border, subtle
var border2       = "#22FF9898"      // pink border, subtle

// ── Hover / selection ─────────────────────────────────────────
var hoverBg       = "#44FF9898"      // pink hover background
var hoverBorder   = "#CCFF9898"      // pink hover border
var selectedBg    = "#55FF6557"      // redorange selected background
var selectedBorder= "#CCFFDCA0"      // peach selected border

// ── Gradient stops ────────────────────────────────────────────
var grad1         = "#ffca98"        // pale amber
var grad2         = "#F4A340"        // orange
var grad3         = "#FF6557"        // redorange
var grad4         = "#FF9898"        // pink
var grad5         = "#FF6557"        // redorange

// ── Typography ────────────────────────────────────────────────
var fontFamily    = "Google Sans Display"
var fontFamilyMono= "JetBrains Mono"

// ── Paths ─────────────────────────────────────────────────────
var backgroundImage = "/usr/share/sddm/themes/solr-dark/assets/background.png"
var logoImage       = "/usr/share/sddm/themes/solr-dark/assets/logo.png"

// ── Scripts ───────────────────────────────────────────────────
var scriptWeather    = "/home/kazuki/.config/weather/weather-read.sh"
var scriptNowPlaying = "/home/kazuki/.config/hypr/scripts/lock-nowplaying.sh"
var scriptBattery    = "/home/kazuki/.config/hypr/scripts/lock-battery.sh"

// ── Power scripts ─────────────────────────────────────────────
var scriptPowerOff   = "/home/kazuki/.local/bin/cmd-shutdown"
var scriptReboot     = "/home/kazuki/.local/bin/cmd-reboot"
