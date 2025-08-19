return {
  "tpope/vim-fugitive",
  config = function()
    Brown.keymaps.g:add({
      "g",
      "<cmd>tab Git<CR>",
      desc = "open Fu[g]itive",
    }, {
      "B",
      "<cmd>Git blame<CR>",
      desc = "Git [B]lame this buffer",
    }, {
      "L",
      "<cmd>vertical Git log --oneline %<CR>",
      desc = "[L]og this buffer",
    }, {
      "du",
      "<cmd>tab Git diff<CR>",
      desc = "[d]iff [u]nstaged",
    }, {
      "ds",
      "<cmd>tab Git diff --staged<CR>",
      desc = "[d]iff [s]taged",
    })
  end,
}
