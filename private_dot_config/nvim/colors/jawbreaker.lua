vim.cmd.colorscheme("vim")
vim.o.background = "dark"
vim.g.colors_name = "jawbreaker"
-- vim.api.nvim_set_hl(0, "Normal", { bg = "#5b003c" })
local warm_black = "#130d08"
local sand_body = "#ffe1c7"
local grey_sand = "#a89b8f"
local the_white = "#fff1e5"
local explosive_orange = "#ff7e28"
local yeah_violet = "#5f37e5"
local breathe_violet = "#7d58fb"
local you_bright_purple = "#aba2fa"
local her_cerulean = "#38a3ff"
local light_green = "#8cffbe"
local butter_cat = "#ffda48"
local baby_red = "#fe4747"
local size_magenta = "#ff9cf2"
local purest_cyan = "#83e9f0"
vim.api.nvim_set_hl(0, "Normal", {
  fg = the_white,
  bg = warm_black,
})
vim.api.nvim_set_hl(0, "Comment", {
  fg = grey_sand,
})
vim.api.nvim_set_hl(0, "Statement", {
  fg = explosive_orange,
  -- fg = baby_red,
})
vim.api.nvim_set_hl(0, "Operator", {
  -- fg = the_white,
  -- fg = size_magenta,
  -- fg = explosive_orange,
  fg = baby_red,
})
vim.api.nvim_set_hl(0, "Delimiter", {
  -- fg = the_white,
  -- fg = baby_red,
  -- fg = size_magenta,
  fg = breathe_violet,
})
vim.api.nvim_set_hl(0, "@constructor.lua", {
  link = "Delimiter",
})
vim.api.nvim_set_hl(0, "Constant", {
  -- fg = the_white,
  -- fg = size_magenta,
  fg = purest_cyan,
})
vim.api.nvim_set_hl(0, "@string.special.symbol.ruby", {
  link = "Constant",
})
vim.api.nvim_set_hl(0, "Type", {
  -- fg = the_white,
  -- fg = her_cerulean,
  -- fg = butter_cat,
  fg = light_green,
})
vim.api.nvim_set_hl(0, "Function", {
  fg = her_cerulean,
  -- fg = the_white,
})
vim.api.nvim_set_hl(0, "Special", {
  fg = you_bright_purple,
  -- fg = the_white,
})
vim.api.nvim_set_hl(0, "Identifier", {
  fg = the_white,
})
vim.api.nvim_set_hl(0, "@variable", {
  fg = the_white,
})
vim.api.nvim_set_hl(0, "@variable.member", {
  fg = size_magenta,
})
vim.api.nvim_set_hl(0, "String", {
  -- fg = light_green,
  fg = butter_cat,
})
--       • {val}    (`vim.api.keyset.highlight`) Highlight definition map,
--                 accepts the following keys:
--                 • fg: color name or "#RRGGBB", see note.
--                 • bg: color name or "#RRGGBB", see note.
--                 • sp: color name or "#RRGGBB"
--                 • blend: integer between 0 and 100
--                 • bold: boolean
--                 • standout: boolean
--                 • underline: boolean
--                 • undercurl: boolean
--                 • underdouble: boolean
--                 • underdotted: boolean
--                 • underdashed: boolean
--                 • strikethrough: boolean
--                 • italic: boolean
--                 • reverse: boolean
--                 • nocombine: boolean
--                 • link: name of another highlight group to link to, see
--                   |:hi-link|.
--                 • default: Don't override existing definition |:hi-default|
--                 • ctermfg: Sets foreground of cterm color |ctermfg|
--                 • ctermbg: Sets background of cterm color |ctermbg|
--                 • cterm: cterm attribute map, like |highlight-args|. If not
--                   set, cterm attributes will match those from the attribute
--                   map documented above.
--                 • force: if true force update the highlight group when it
--                   exists.
