return {
  -- Adds git related signs to the gutter, as well as utilities
  -- for managing changes
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function()
        local gitsigns = require("gitsigns")

        Brown.keymaps.g:add(
          {
            "]",
            function()
              if vim.wo.diff then
                vim.cmd.normal({ "<leader>g]", bang = true })
              else
                gitsigns.nav_hunk("next", nil)
              end
            end,
            desc = "Jump to next git change",
          },
          {
            "[",
            function()
              if vim.wo.diff then
                vim.cmd.normal({ "<leader>g[", bang = true })
              else
                gitsigns.nav_hunk("prev")
              end
            end,
            desc = "Jump to previous git change",
          },
          {
            mode = "v",
            "s",
            function()
              gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end,
            desc = "git [s]tage hunk",
          },
          { "s", gitsigns.stage_hunk, desc = "git [s]tage hunk" },
          {
            mode = "v",
            "r",
            function()
              gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end,
            desc = "git [r]eset hunk",
          },
          { "r", gitsigns.reset_hunk, desc = "git [r]eset hunk" },
          { "S", gitsigns.stage_buffer, desc = "git [S]tage buffer" }
        )

        Brown.keymaps.t.add({
          "g",
          gitsigns.toggle_signs,
          desc = "[T]oggle [g]it signs",
        })
      end,
    },
  },
}
