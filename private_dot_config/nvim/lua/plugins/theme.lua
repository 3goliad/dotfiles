return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "darker",
    })
    -- Enable theme
    require("onedark").load()
  end,
}

-- return {
--   "olimorris/onedarkpro.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     local helpers = "require'onedarkpro.helpers'"
--     require("onedarkpro").setup({
--       colors = {
--         white = helpers .. ".lighten('white', 18, 'onedark_dark')",
--         pink = helpers .. ".lighten('red', 15, 'onedark_dark')",
--       },
--       highlights = {
--         ["@variable"] = { fg = "${white}" },
--         ["@variable.member"] = { fg = "${pink}" },
--         -- Identifier = { fg = "${pink}" },
--         -- ["@variable.ruby"] = { link = "Identifier" },
--         -- ["@variable.parameter.ruby"] = { link = "@variable.ruby" },
--         ["@string.special.symbol.ruby"] = { fg = "${cyan}" },
--         ["@odp.colon.ruby"] = { link = "@string.special.symbol.ruby" },
--         ["@function.builtin.ruby"] = { link = "Keyword" },
--         ["@variable.builtin.ruby"] = { link = "Keyword" },
--         ["@label.ruby"] = { fg = "${orange}" },
--       },
--     })
--     vim.cmd([[colorscheme onedark_dark]])
--   end,
-- }
