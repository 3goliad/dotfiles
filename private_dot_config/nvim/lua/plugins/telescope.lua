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
      "nvim-telescope/telescope-project.nvim",
      -- { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          project = {
            on_project_selected = function(prompt_bufnr)
              local project_actions =
                require("telescope._extensions.project.actions")
              local cowed_tabline = require("cowed-tabline")

              local title = project_actions.get_selected_title(prompt_bufnr)

              local tab_id = cowed_tabline.find_tab_id_by_name(title)
              if tab_id then
                vim.schedule(function()
                  vim.api.nvim_set_current_tabpage(tab_id)
                end)
              else
                vim.cmd.tabnew()
                vim.schedule(function()
                  local path = project_actions.get_selected_path(prompt_bufnr)
                  vim.cmd.tchdir(path)
                  cowed_tabline.set_tab_name(title)
                  require("telescope.builtin").find_files()
                end)
              end
            end,
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("project")

      -- See `:help telescope.builtin`
      local tb = require("telescope.builtin")
      Brown.keymaps:add({
        "<leader><leader>",
        tb.find_files,
        desc = "[ ] search files in this tree",
      })
      Brown.keymaps.s:add(
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
        }
      )
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
      local tele_project = require("telescope").extensions.project
      Brown.keymaps.p:add({
        "p",
        tele_project.project,
        desc = "switch to [p]roject tab",
      })
    end,
  },
}
