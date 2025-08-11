return {
  "tpope/vim-fugitive",
  config = function()
    Brown.keymaps.g:add({
      "g",
      "<cmd>Git<CR>",
      desc = "open Fu[g]itive",
    }, {
      "b",
      "<cmd>Git blame<CR>",
      desc = "Git [b]lame this buffer",
    })
  end,
}
