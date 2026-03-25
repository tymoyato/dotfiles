-- Cyberdream Light theme for NvChad
-- https://github.com/scottmckendry/cyberdream.nvim

local M = {}

M.base_30 = {
    white = "#16181a",
    darker_black = "#f5f5f5",
    black = "#ffffff", -- nvim bg
    black2 = "#eaeaea", -- statusline, float bg
    one_bg = "#e0e0e0",
    one_bg2 = "#d6d6d6",
    one_bg3 = "#acacac",
    grey = "#c0c0c0",
    grey_fg = "#b6b6b6",
    grey_fg2 = "#acacac",
    light_grey = "#7b8496",
    red = "#d11500",
    baby_pink = "#f40064",
    pink = "#d100bf",
    line = "#e0e0e0", -- for lines like vertsplit
    green = "#008b0c",
    vibrant_green = "#009b1c",
    nord_blue = "#0057d1",
    blue = "#0057d1",
    yellow = "#997b00",
    sun = "#d17c00",
    purple = "#a018ff",
    dark_purple = "#9008ef",
    teal = "#008c99",
    orange = "#d17c00",
    cyan = "#008c99",
    statusline_bg = "#eaeaea",
    lightbg = "#e0e0e0",
    pmenu_bg = "#0057d1",
    folder_bg = "#0057d1",
}

M.base_16 = {
    base00 = "#ffffff", -- Default Background
    base01 = "#eaeaea", -- Lighter Background (Used for status bars, line number and folding marks)
    base02 = "#acacac", -- Selection Background
    base03 = "#c0c0c0", -- Comments, Invisibles, Line Highlighting
    base04 = "#7b8496", -- Dark Foreground (Used for status bars)
    base05 = "#16181a", -- Default Foreground, Caret, Delimiters, Operators
    base06 = "#16181a", -- Light Foreground (Not often used)
    base07 = "#16181a", -- Light Background (Not often used)
    base08 = "#d11500", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = "#d17c00", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = "#997b00", -- Classes, Markup Bold, Search Text Background
    base0B = "#008b0c", -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = "#008c99", -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = "#0057d1", -- Functions, Methods, Attribute IDs, Headings
    base0E = "#a018ff", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = "#f40064", -- Deprecated, Opening/Closing Embedded Language Tags
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

M.type = "light"

M.transparency = true

return M
