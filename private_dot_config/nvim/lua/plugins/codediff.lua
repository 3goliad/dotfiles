return {
  "esmuellert/codediff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  config = function()
    require("codediff").setup({
      explorer = {
        position = "bottom",
        height = 14,
      },
    })

    vim.keymap.set(
      "n",
      "<leader>gD",
      "<cmd>CodeDiff<CR>",
      { desc = "Code[D]iff" }
    )
  end,
}
