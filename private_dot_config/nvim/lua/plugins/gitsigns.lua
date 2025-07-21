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
          { "b", gitsigns.blame, desc = "[G]it [B]lame" },
          { "S", gitsigns.stage_buffer, desc = "[G]it [S]tage buffer" },
          { "R", gitsigns.reset_buffer, desc = "[G]it [R]eset buffer" }
        )

        Brown.keymaps.g.h:add({
          "]",
          function()
            if vim.wo.diff then
              vim.cmd.normal({ "<leader>gh]", bang = true })
            else
              gitsigns.nav_hunk("next", nil)
            end
          end,
          desc = "Jump to next [G]it [h]unk",
        }, {
          "[",
          function()
            if vim.wo.diff then
              vim.cmd.normal({ "<leader>gh[", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end,
          desc = "Jump to previous [G]it [h]unk",
        }, {
          mode = "v",
          "s",
          function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end,
          desc = "[S]tage this [G]it [h]unk",
        }, {
          "s",
          gitsigns.stage_hunk,
          desc = "[S]tage this [G]it [h]unk",
        }, {
          mode = "v",
          "r",
          function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end,
          desc = "[R]eset this [G]it [h]unk",
        }, {
          "r",
          gitsigns.reset_hunk,
          desc = "[R]eset this [G]it [h]unk",
        }, {
          "p",
          gitsigns.preview_hunk,
          desc = "[P]review this [G]it [h]unk",
        })
      end,
    },
  },
}
