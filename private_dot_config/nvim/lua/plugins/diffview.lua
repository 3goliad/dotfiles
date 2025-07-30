return {
  "sindrets/diffview.nvim",
  opts = {
    view = {
      default = {
        layout = "diff2_horizontal",
      },
    },
    file_panel = {
      win_config = {
        position = "bottom",
        height = 14,
      },
    },
    key_bindings = {
      file_history_panel = { q = "<cmd>DiffviewClose<CR>" },
      file_panel = { q = "<cmd>DiffviewClose<CR>" },
      view = { q = "<cmd>DiffviewClose<CR>" },
    },
  },
}
