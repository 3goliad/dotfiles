return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.pairs").setup()
    require("mini.misc").setup()
    require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })

    require("mini.trailspace").setup()
    Brown.keymaps.b:add({
      "s",
      function()
        MiniTrailspace.trim()
        MiniTrailspace.trim_last_lines()
      end,
      desc = "[s]trip trailing whitespace",
    })

    require("mini.bufremove").setup()
    Brown.keymaps.b:add({ "k", MiniBufremove.delete, desc = "[B]uffer [K]ill" })

    require("mini.files").setup()
    Brown.keymaps.f:add({
      "f",
      function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
      end,
      desc = "Browse at this [f]ile",
    }, {
      "l",
      MiniFiles.open,
      desc = "Open [l]ast file browser",
    })

    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    -- require("mini.ai").setup({ n_lines = 500 })

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    -- require("mini.surround").setup()
  end,
}
