return {
  "nvim-mini/mini.nvim",
  config = function()
    require("mini.pairs").setup()
    require("mini.misc").setup()
    require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })

    require("mini.trailspace").setup()
    vim.keymap.set("n", "<leader>bt", function()
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end, {
      desc = "[t]rim trailing whitespace",
    })

    require("mini.bufremove").setup()
    vim.keymap.set(
      "n",
      "<leader>bt",
      MiniBufremove.delete,
      { desc = "[B]uffer [K]ill" }
    )

    require("mini.files").setup()
    vim.keymap.set("n", "<leader>ff", function()
      MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    end, { desc = "Browse at this [f]ile" })
    vim.keymap.set(
      "n",
      "<leader>fl",
      MiniFiles.open,
      { desc = "Open [l]ast file browser" }
    )

    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup()

    require("mini.splitjoin").setup()

    require("mini.hipatterns").setup({
      highlighters = {
        fixme = {
          pattern = "%f[%w]()FIXME()%f[%W]",
          group = "MiniHipatternsFixme",
        },
        hack = {
          pattern = "%f[%w]()HACK()%f[%W]",
          group = "MiniHipatternsHack",
        },
        todo = {
          pattern = "%f[%w]()TODO()%f[%W]",
          group = "MiniHipatternsTodo",
        },
        note = {
          pattern = "%f[%w]()NOTE()%f[%W]",
          group = "MiniHipatternsNote",
        },
      },
    })
  end,
}
