-- Cyberdream theme for NvChad
-- https://github.com/scottmckendry/cyberdream.nvim

local M = {}

M.base_30 = {
    white = "#ffffff",
    darker_black = "#12141a",
    black = "#16181a", -- nvim bg
    black2 = "#1e2124", -- statusline, float bg
    one_bg = "#24262a",
    one_bg2 = "#2a2c30",
    one_bg3 = "#3c4048",
    grey = "#545862",
    grey_fg = "#5e626e",
    grey_fg2 = "#696d79",
    light_grey = "#7b8496",
    red = "#ff6e5e",
    baby_pink = "#ff5ea0",
    pink = "#ff5ef1",
    line = "#24262a", -- for lines like vertsplit
    green = "#5eff6c",
    vibrant_green = "#6eff7c",
    nord_blue = "#5ea1ff",
    blue = "#5ea1ff",
    yellow = "#f1ff5e",
    sun = "#ffbd5e",
    purple = "#bd5eff",
    dark_purple = "#ad4eef",
    teal = "#5ef1ff",
    orange = "#ffbd5e",
    cyan = "#5ef1ff",
    statusline_bg = "#1e2124",
    lightbg = "#24262a",
    pmenu_bg = "#5ea1ff",
    folder_bg = "#5ea1ff",
}

M.base_16 = {
    base00 = "#16181a", -- Default Background
    base01 = "#1e2124", -- Lighter Background (Used for status bars, line number and folding marks)
    base02 = "#3c4048", -- Selection Background
    base03 = "#545862", -- Comments, Invisibles, Line Highlighting
    base04 = "#7b8496", -- Dark Foreground (Used for status bars)
    base05 = "#ffffff", -- Default Foreground, Caret, Delimiters, Operators
    base06 = "#ffffff", -- Light Foreground (Not often used)
    base07 = "#ffffff", -- Light Background (Not often used)
    base08 = "#ff6e5e", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = "#ffbd5e", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = "#f1ff5e", -- Classes, Markup Bold, Search Text Background
    base0B = "#5eff6c", -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = "#5ef1ff", -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = "#5ea1ff", -- Functions, Methods, Attribute IDs, Headings
    base0E = "#bd5eff", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = "#ff5ea0", -- Deprecated, Opening/Closing Embedded Language Tags
}

M.polish_hl = {
    treesitter = {
        ["@variable"] = { fg = M.base_30.white },
        ["@variable.builtin"] = { fg = M.base_30.red },
        ["@variable.parameter"] = { fg = M.base_30.white },
        ["@variable.member"] = { fg = M.base_30.blue },

        ["@module"] = { fg = M.base_30.cyan },
        ["@constant"] = { fg = M.base_30.orange },
        ["@constant.builtin"] = { fg = M.base_30.orange },

        ["@string"] = { fg = M.base_30.green },
        ["@string.escape"] = { fg = M.base_30.cyan },
        ["@string.regexp"] = { fg = M.base_30.cyan },

        ["@character"] = { fg = M.base_30.green },
        ["@number"] = { fg = M.base_30.orange },
        ["@boolean"] = { fg = M.base_30.orange },

        ["@function"] = { fg = M.base_30.blue },
        ["@function.builtin"] = { fg = M.base_30.cyan },
        ["@function.call"] = { fg = M.base_30.blue },
        ["@function.macro"] = { fg = M.base_30.cyan },

        ["@method"] = { fg = M.base_30.blue },
        ["@method.call"] = { fg = M.base_30.blue },

        ["@constructor"] = { fg = M.base_30.cyan },
        ["@parameter"] = { fg = M.base_30.white },

        ["@keyword"] = { fg = M.base_30.purple },
        ["@keyword.function"] = { fg = M.base_30.purple },
        ["@keyword.operator"] = { fg = M.base_30.purple },
        ["@keyword.return"] = { fg = M.base_30.purple },

        ["@conditional"] = { fg = M.base_30.purple },
        ["@repeat"] = { fg = M.base_30.purple },
        ["@label"] = { fg = M.base_30.purple },

        ["@operator"] = { fg = M.base_30.cyan },
        ["@exception"] = { fg = M.base_30.purple },

        ["@type"] = { fg = M.base_30.cyan },
        ["@type.builtin"] = { fg = M.base_30.cyan },
        ["@type.qualifier"] = { fg = M.base_30.purple },

        ["@property"] = { fg = M.base_30.blue },
        ["@field"] = { fg = M.base_30.blue },

        ["@tag"] = { fg = M.base_30.purple },
        ["@tag.attribute"] = { fg = M.base_30.blue },
        ["@tag.delimiter"] = { fg = M.base_30.cyan },
    },

    -- Transparency support
    Normal = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    NvimTreeNormal = { bg = "NONE" },
    NvimTreeNormalNC = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    EndOfBuffer = { bg = "NONE" },
}

M.type = "dark"

M.transparency = true

return M
