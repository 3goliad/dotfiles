return {
  "esmuellert/codediff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  config = function()
    require("codediff").setup({
      explorer = {
        position = "bottom",
        height = "14",
      },
      keymaps = {
        view = {
          diff_get = "<leader>do",
          diff_put = "<leader>dp",
        },
      },
    })
  end,
}
