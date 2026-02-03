return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato", -- dark base
			transparent_background = false, -- set true if you want Hyprland blur behind
			term_colors = true,

			-- SOLR UI + restored semantic palette for code readability (no purple hexes)
			color_overrides = {
				macchiato = {
					-- Base stack (Omarchy dark)
					base = "#2E3440",
					mantle = "#252b36",
					crust = "#1f2430",

					-- Text (warm cream)
					text = "#FFF8D6",
					subtext1 = "#EFE4C8",
					subtext0 = "#D9CFB4",

					-- Surfaces
					surface0 = "#343c4a",
					surface1 = "#3b4352",
					surface2 = "#465064",

					-- Overlays (neutral grays)
					overlay0 = "#6C7086",
					overlay1 = "#7F849C",
					overlay2 = "#9399B2",

					-- SOLR thermal accents
					red = "#FF6557", -- ember coral
					maroon = "#FF6557",
					flamingo = "#FF9898", -- hot salmon
					pink = "#FF9898",
					peach = "#F4A340", -- solar orange
					yellow = "#FFDCA0", -- soft gold
					rosewater = "#FFCA98", -- peach

					-- Semantic cools (muted, readable, NOT purple)
					green = "#A3BE8C", -- sage green (strings / diff add vibes)
					teal = "#8FBCBB", -- muted teal (hints)
					sky = "#88C0D0", -- soft cyan (operators / specials)
					sapphire = "#81A1C1", -- steel blue (types)
					blue = "#5E81AC", -- deeper blue (keywords/functions accents)

					-- “Purple slots” mapped to non-purple semantics
					mauve = "#5E81AC", -- map to deeper blue
					lavender = "#81A1C1", -- map to steel blue
				},
			},

			-- Fine-grain: keep UI thermal/SOLR (syntax still gets full palette)
			custom_highlights = function(C)
				local coral = "#FF6557"
				local orange = "#F4A340"
				local salmon = "#FF9898"
				local peach = "#FFCA98"
				local gold = "#FFDCA0"

				return {
					-- Editor UI
					Normal = { fg = C.text, bg = C.base },
					NormalFloat = { fg = C.text, bg = C.mantle },
					FloatBorder = { fg = orange, bg = C.mantle },

					CursorLine = { bg = C.surface0 },
					CursorLineNr = { fg = orange, style = { "bold" } },
					LineNr = { fg = C.overlay0 },
					VertSplit = { fg = C.surface1 },
					WinSeparator = { fg = C.surface1 },

					Visual = { bg = C.surface2 },
					Search = { fg = C.base, bg = gold, style = { "bold" } },
					IncSearch = { fg = C.base, bg = orange, style = { "bold" } },

					Pmenu = { fg = C.text, bg = C.mantle },
					PmenuSel = { fg = C.base, bg = peach, style = { "bold" } },
					PmenuSbar = { bg = C.surface0 },
					PmenuThumb = { bg = C.overlay0 },

					-- Diagnostics (thermal scale)
					DiagnosticError = { fg = coral },
					DiagnosticWarn = { fg = orange },
					DiagnosticInfo = { fg = peach },
					DiagnosticHint = { fg = gold },

					-- Git signs (warm, matches your SOLR look)
					GitSignsAdd = { fg = gold },
					GitSignsChange = { fg = orange },
					GitSignsDelete = { fg = coral },

					-- Telescope / borders (thermal)
					LspInfoBorder = { fg = orange },
					TelescopeBorder = { fg = orange },
					TelescopePromptBorder = { fg = orange },
					TelescopeSelection = { bg = C.surface0 },
					TelescopeMatching = { fg = salmon, style = { "bold" } },

					-- WhichKey
					WhichKeyBorder = { fg = orange },
					WhichKeyFloat = { bg = C.mantle },

					-- Statusline
					StatusLine = { fg = C.text, bg = C.mantle },
					StatusLineNC = { fg = C.overlay0, bg = C.mantle },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin") -- uses flavour above (macchiato)
		end,
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
}
