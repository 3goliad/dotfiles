return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 50,
      spec = {
        { prefix = "<leader>f", group = "[F]ile" },
        { prefix = "<leader>t", group = "[T]oggle" },
        { prefix = "<leader>w", group = "[W]indow" },
        { prefix = "<leader>b", group = "[B]uffer" },
        { prefix = "<leader>g", group = "[G]it" },
        { prefix = "<leader>gh", group = "[G]it [H]unk" },
        { prefix = "<leader>s", group = "[S]earch" },
        { prefix = "<leader>m", group = "Filetype ([M]ode)" },
        { prefix = "<leader>p", group = "[P]roject" },
        { prefix = "<leader>i", group = "[I]nspect" },
      },
    },
  },
}
