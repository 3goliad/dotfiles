return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim",
  },
  opts = {
    commit_editor = {
      staged_diff_split_kind = "auto",
    },
  },
  -- config = function()
  --   -- add = { text = "+" },
  --   -- change = { text = "~" },
  --   -- delete = { text = "_" },
  --   -- topdelete = { text = "‾" },
  --   -- changedelete = { text = "~" },
  --   local neogit = require("neogit")
  --   Brown.keymaps.g:add({
  --     "g",
  --     neogit.open,
  --     desc = "open Neo[g]it",
  --   }, {
  --     "l",
  --     function()
  --       neogit.open({ "log" })
  --     end,
  --     desc = "Open Git [l]og for current file",
  --   }, {
  --     "L",
  --     "<cmd>NeogitLog<CR>",
  --     desc = "Open Git [l]og for current file",
  --   })
  -- end,
}
