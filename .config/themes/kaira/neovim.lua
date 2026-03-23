return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato", -- dark base
			transparent_background = false, -- set true if you want Hyprland blur behind
			term_colors = true,

			-- LUNR UI + full semantic palette for code readability
			-- Anchors from your fastfetch LUNR palette:
			-- moonlight #AFC5DA, moonglow #FEFBD0, lilac #B48EAD, gold #FFDCA0, muted purple #605A80
			color_overrides = {
				macchiato = {
					-- Base stack (Omarchy dark)
					base = "#2E3440",
					mantle = "#252b36",
					crust = "#1f2430",

					-- Text (moon-glow)
					text = "#FEFBD0",
					subtext1 = "#E7E4C2",
					subtext0 = "#D1CEAD",

					-- Surfaces
					surface0 = "#343c4a",
					surface1 = "#3b4352",
					surface2 = "#465064",

					-- Overlays (muted lunar purples/steels)
					overlay0 = "#605A80", -- muted purple (shadow/lines)
					overlay1 = "#6E688F",
					overlay2 = "#857FA3",

					-- LUNR accents
					red = "#B48EAD", -- lilac (severity/attention)
					maroon = "#B48EAD",
					flamingo = "#AFC5DA", -- moonlight blue
					pink = "#AFC5DA",
					peach = "#FFDCA0", -- soft gold
					yellow = "#FEFBD0", -- moonglow
					rosewater = "#FEFBD0",

					-- Semantic cools (muted; keep code readable)
					green = "#A3BE8C", -- sage (strings)
					teal = "#8FBCBB", -- teal (hints)
					sky = "#88C0D0", -- cyan (specials)
					sapphire = "#AFC5DA", -- moonlight (types)
					blue = "#81A1C1", -- steel (keywords/functions)

					-- Purple slots stay lunar (not hot neon)
					mauve = "#B48EAD", -- lilac
					lavender = "#AFC5DA", -- moonlight
				},
			},

			-- Fine-grain: make UI elements look like your LUNR borders + glow (moonglow/lilac/moonlight)
			custom_highlights = function(C)
				local moonglow = "#FEFBD0"
				local moonlight = "#AFC5DA"
				local lilac = "#B48EAD"
				local gold = "#FFDCA0"
				local shadow = "#605A80"

				return {
					-- Editor UI
					Normal = { fg = C.text, bg = C.base },
					NormalFloat = { fg = C.text, bg = C.mantle },
					FloatBorder = { fg = moonlight, bg = C.mantle },

					CursorLine = { bg = C.surface0 },
					CursorLineNr = { fg = moonglow, style = { "bold" } },

					LineNr = { fg = shadow },
					VertSplit = { fg = C.surface1 },
					WinSeparator = { fg = C.surface1 },

					Visual = { bg = C.surface2 },
					Search = { fg = C.base, bg = gold, style = { "bold" } },
					IncSearch = { fg = C.base, bg = lilac, style = { "bold" } },

					Pmenu = { fg = C.text, bg = C.mantle },
					PmenuSel = { fg = C.base, bg = moonglow, style = { "bold" } },
					PmenuSbar = { bg = C.surface0 },
					PmenuThumb = { bg = shadow },

					-- Diagnostics (lunar: lilac -> gold -> moonlight -> shadow)
					DiagnosticError = { fg = lilac },
					DiagnosticWarn = { fg = gold },
					DiagnosticInfo = { fg = moonlight },
					DiagnosticHint = { fg = shadow },

					-- Git
					GitSignsAdd = { fg = moonlight },
					GitSignsChange = { fg = gold },
					GitSignsDelete = { fg = lilac },

					-- LSP / UI popups
					LspInfoBorder = { fg = moonlight },
					TelescopeBorder = { fg = moonlight },
					TelescopePromptBorder = { fg = moonlight },
					TelescopeSelection = { bg = C.surface0 },
					TelescopeMatching = { fg = lilac, style = { "bold" } },

					-- WhichKey
					WhichKeyBorder = { fg = moonlight },
					WhichKeyFloat = { bg = C.mantle },

					-- Statusline vibe (moon chips)
					StatusLine = { fg = C.text, bg = C.mantle },
					StatusLineNC = { fg = shadow, bg = C.mantle },
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
