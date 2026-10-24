return {
    {
        "bjarneo/aether.nvim",
        name = "aether",
        priority = 1000,
        opts = {
            disable_italics = false,
            colors = {
                -- Monotone shades (base00-base07)
                base00 = "#14111A", -- Default background
                base01 = "#43384C", -- Lighter background (status bars)
                base02 = "#14111A", -- Selection background
                base03 = "#43384C", -- Comments, invisibles
                base04 = "#E7DFE9", -- Dark foreground
                base05 = "#D8D0DC", -- Default foreground
                base06 = "#D8D0DC", -- Light foreground
                base07 = "#E7DFE9", -- Light background

                -- Accent colors (base08-base0F)
                base08 = "#8D5F74", -- Variables, errors, red
                base09 = "#B57A92", -- Integers, constants, orange
                base0A = "#9A84A2", -- Classes, types, yellow
                base0B = "#6F7B8F", -- Strings, green
                base0C = "#7E95C1", -- Support, regex, cyan
                base0D = "#A87692", -- Functions, keywords, blue
                base0E = "#947598", -- Keywords, storage, magenta
                base0F = "#BEA2C7", -- Deprecated, brown/yellow
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
