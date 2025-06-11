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
      { "nvim-telescope/telescope-file-browser.nvim" },
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
      require("telescope").load_extension("file_browser")

      -- See `:help telescope.builtin`
      local tb = require("telescope.builtin")
      vim.keymap.set(
        "n",
        "<leader><leader>",
        tb.find_files,
        { desc = "[ ] search files in this tree" }
      )
      vim.keymap.set(
        "n",
        "<leader>sh",
        tb.help_tags,
        { desc = "[S]earch [H]elp" }
      )
      vim.keymap.set(
        "n",
        "<leader>sk",
        tb.keymaps,
        { desc = "[S]earch [K]eymaps" }
      )
      vim.keymap.set(
        "n",
        "<leader>ff",
        ":Telescope file_browser<CR>",
        { desc = "[F]ind [F]iles" }
      )
      vim.keymap.set(
        "n",
        "<leader>ss",
        tb.builtin,
        { desc = "[S]earch [S]elect Telescope" }
      )
      vim.keymap.set(
        "n",
        "<leader>sw",
        tb.grep_string,
        { desc = "[S]earch current [W]ord" }
      )
      vim.keymap.set(
        "n",
        "<leader>sg",
        tb.live_grep,
        { desc = "[S]earch by [G]rep" }
      )
      vim.keymap.set(
        "n",
        "<leader>sd",
        tb.diagnostics,
        { desc = "[S]earch [D]iagnostics" }
      )
      vim.keymap.set(
        "n",
        "<leader>sr",
        tb.resume,
        { desc = "[S]earch [R]esume" }
      )
      vim.keymap.set(
        "n",
        "<leader>f.",
        tb.oldfiles,
        { desc = '[F]ind Recent File ("." for repeat)' }
      )
      vim.keymap.set(
        "n",
        "<leader>bb",
        tb.buffers,
        { desc = "[B]ounce to [B]uffer" }
      )

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>sb", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        tb.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[S]earch this [B]uffer" })
    end,
  },
}
