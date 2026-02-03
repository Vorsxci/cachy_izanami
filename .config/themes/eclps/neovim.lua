return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = false,
			term_colors = true,

			-- ECLPS palette: ash/silver base + soft gold accents
			color_overrides = {
				macchiato = {
					-- Base stack (Omarchy dark)
					base = "#2E3440",
					mantle = "#252b36",
					crust = "#1f2430",

					-- Text (moon-glow / warm neutral)
					text = "#F2F1EA",
					subtext1 = "#DAD8D0",
					subtext0 = "#BFC0BC",

					-- Surfaces (cool ash)
					surface0 = "#343c4a",
					surface1 = "#3b4352",
					surface2 = "#465064",

					-- Overlays (neutral grays)
					overlay0 = "#6C7086",
					overlay1 = "#7F849C",
					overlay2 = "#9399B2",

					-- ECLPS accents
					yellow = "#FFDCA0", -- soft gold (primary accent)
					peach = "#FF8E5A", -- subtle orange glow (rare, for "hot" emphasis)
					rosewater = "#FEFBD0", -- moon glow (secondary highlight)
					lavender = "#AFC5DA", -- moonlight blue (info)
					mauve = "#B48EAD", -- violet (sparkle / match)
					pink = "#B48EAD",
					flamingo = "#B48EAD",

					-- Keep "red" real but not SOLR-hot
					red = "#E06C75",
					maroon = "#E06C75",

					-- Semantics (cool, readable)
					green = "#A3BE8C",
					teal = "#8FBCBB",
					sky = "#88C0D0",
					sapphire = "#81A1C1",
					blue = "#5E81AC",
				},
			},

			custom_highlights = function(C)
				-- ECLPS key tones (explicit so tweaks are easy)
				local gold = "#FFDCA0" -- soft gold
				local moon = "#FEFBD0" -- moon glow
				local ash = "#AFC5DA" -- moonlight blue
				local violet = "#B48EAD" -- rare violet
				local glow = "#FF8E5A" -- faint orange glow
				local err = "#E06C75" -- restrained red

				return {
					-- Editor UI
					Normal = { fg = C.text, bg = C.base },
					NormalFloat = { fg = C.text, bg = C.mantle },
					FloatBorder = { fg = gold, bg = C.mantle },

					CursorLine = { bg = C.surface0 },
					CursorLineNr = { fg = gold, style = { "bold" } },
					LineNr = { fg = C.overlay0 },
					VertSplit = { fg = C.surface1 },
					WinSeparator = { fg = C.surface1 },

					-- Selection/search: eclipse gold
					Visual = { bg = C.surface2 },
					Search = { fg = C.base, bg = moon, style = { "bold" } },
					IncSearch = { fg = C.base, bg = gold, style = { "bold" } },

					-- Menus
					Pmenu = { fg = C.text, bg = C.mantle },
					PmenuSel = { fg = C.base, bg = gold, style = { "bold" } },
					PmenuSbar = { bg = C.surface0 },
					PmenuThumb = { bg = C.overlay0 },

					-- Diagnostics (ECLPS: gold-forward, blue info, violet hints)
					DiagnosticError = { fg = err },
					DiagnosticWarn = { fg = gold },
					DiagnosticInfo = { fg = ash },
					DiagnosticHint = { fg = violet },

					-- Git signs (quiet + classy)
					GitSignsAdd = { fg = C.green },
					GitSignsChange = { fg = gold },
					GitSignsDelete = { fg = err },

					-- Telescope / borders (gold rims, violet matches)
					LspInfoBorder = { fg = gold },
					TelescopeBorder = { fg = gold },
					TelescopePromptBorder = { fg = gold },
					TelescopeSelection = { bg = C.surface0 },
					TelescopeMatching = { fg = violet, style = { "bold" } },

					-- WhichKey
					WhichKeyBorder = { fg = gold },
					WhichKeyFloat = { bg = C.mantle },

					-- Statusline (ash + gold edge vibe)
					StatusLine = { fg = C.text, bg = C.mantle },
					StatusLineNC = { fg = C.overlay0, bg = C.mantle },

					-- Optional: tiny “glow orange” only where it feels like accretion shimmer
					Title = { fg = gold, style = { "bold" } },
					Special = { fg = glow },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"LazyVim/LazyVim",
		opts = { colorscheme = "catppuccin" },
	},
}
