return {
    {
        "bjarneo/aether.nvim",
        name = "aether",
        priority = 1000,
        opts = {
            disable_italics = false,
            colors = {
                -- Monotone shades (base00-base07)
                base00 = "#1f1a14", -- Default background
                base01 = "#534c44", -- Lighter background (status bars)
                base02 = "#1f1a14", -- Selection background
                base03 = "#534c44", -- Comments, invisibles
                base04 = "#f4e6c3", -- Dark foreground
                base05 = "#ffffff", -- Default foreground
                base06 = "#ffffff", -- Light foreground
                base07 = "#f4e6c3", -- Light background

                -- Accent colors (base08-base0F)
                base08 = "#d08f53", -- Variables, errors, red
                base09 = "#e8bf98", -- Integers, constants, orange
                base0A = "#ada28b", -- Classes, types, yellow
                base0B = "#e4dbc0", -- Strings, green
                base0C = "#e5c98b", -- Support, regex, cyan
                base0D = "#caaa87", -- Functions, keywords, blue
                base0E = "#d6b28b", -- Keywords, storage, magenta
                base0F = "#d5cec1", -- Deprecated, brown/yellow
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
