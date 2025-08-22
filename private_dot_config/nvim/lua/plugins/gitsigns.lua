return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▁" },
      topdelete = { text = "▔" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    signs_staged = {
      add = { text = "▌" },
      change = { text = "▌" },
      delete = { text = "🬲" },
      topdelete = { text = "🬕" },
      changedelete = { text = "~" },
    },
    preview_config = {
      border = "rounded",
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      vim.keymap.set("n", "<leader>ghp", function()
        gs.preview_hunk()
      end, { buffer = bufnr })
      vim.keymap.set(
        "n",
        "<leader>ghs",
        "<cmd>Gitsigns stage_hunk<CR>",
        { buffer = bufnr }
      )
    end,
  },
}
