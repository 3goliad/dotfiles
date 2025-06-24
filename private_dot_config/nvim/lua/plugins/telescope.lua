return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      -- { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      require("telescope").setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      require("telescope").load_extension("ui-select")
      -- require("telescope").load_extension("file_browser")

      -- See `:help telescope.builtin`
      local tb = require("telescope.builtin")
      Brown.keymaps:add({
        "<leader><leader>",
        tb.find_files,
        desc = "[ ] search files in this tree",
      })
      Brown.keymaps:add_group("s", {
        desc = "[S]earch",
        { "h", tb.help_tags, desc = "[S]earch [H]elp" },
        { "k", tb.keymaps, desc = "[S]earch [K]eymaps" },
        { "s", tb.builtin, desc = "[S]earch [S]elect Telescope" },
        { "w", tb.grep_string, desc = "[S]earch current [W]ord" },
        { "g", tb.live_grep, desc = "[S]earch by [G]rep" },
        { "d", tb.diagnostics, desc = "[S]earch [D]iagnostics" },
        { "r", tb.resume, desc = "[S]earch [R]esume" },
        -- Slightly advanced example of overriding default behavior and theme
        {
          "b",
          function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            tb.current_buffer_fuzzy_find(
              require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
              })
            )
          end,
          desc = "[S]earch this [B]uffer",
        },
      })
      Brown.keymaps.f:add({
        ".",
        tb.oldfiles,
        desc = 'Recent [F]iles ("." for repeat)',
      })
      Brown.keymaps.b:add({
        "b",
        tb.buffers,
        desc = "[B]ounce to [B]uffer",
      })
    end,
  },
}
