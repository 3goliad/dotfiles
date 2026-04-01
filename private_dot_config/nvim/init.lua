require("config.brown")

-- keymaps and typing
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.timeoutlen = 500
vim.o.confirm = true
-- display
vim.g.have_nerd_font = true
vim.o.updatetime = 350
vim.o.number = true
vim.o.numberwidth = 3
vim.o.showmode = false
vim.o.signcolumn = "auto:1-2"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.showtabline = 1
-- code folding
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 10
-- state and history
vim.o.undofile = true
vim.opt.messagesopt = { "hit-enter", "history:2000" }
-- formatting
vim.o.breakindent = true
vim.o.fixendofline = false -- don't fix up old files
vim.o.tabstop = 8
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
-- searching
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"
-- windows
vim.o.splitright = true
vim.o.splitbelow = true
-- diffs
vim.opt.diffopt = {
  "algorithm:patience",
  "internal",
  "indent-heuristic",
  "filler",
  "closeoff",
  "linematch:80",
}

vim.diagnostic.config({
  underline = true,
  -- underline = { severity = vim.diagnostic.severity.ERROR },
  severity_sort = true,
  -- virtual_lines = { current_line = true },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("yank-highlighting", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
  desc = "Open diagnostic [Q]uickfix list",
})
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {
  desc = "Exit terminal mode",
})

-- Splitting windows
vim.keymap.set(
  "n",
  "<leader>wv",
  "<C-w>v",
  { desc = "[W]indow [V]ertical Split" }
)
vim.keymap.set(
  "n",
  "<leader>ws",
  "<C-w>s",
  { desc = "[W]indow [H]orizontal Split" }
)
-- Closing windows
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "[W]indow [C]lose" })
-- Switching windows
vim.keymap.set("n", "<leader>wh", "<C-w><C-h>", { desc = "Focus left window" })
vim.keymap.set("n", "<leader>wl", "<C-w><C-l>", { desc = "Focus right window" })
vim.keymap.set("n", "<leader>wj", "<C-w><C-j>", { desc = "Focus lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w><C-k>", { desc = "Focus upper window" })
-- Moving windows
vim.keymap.set("n", "<leader>wH", "<C-w>H", { desc = "Move window far left" })
vim.keymap.set("n", "<leader>wL", "<C-w>L", { desc = "Move window far right" })
vim.keymap.set("n", "<leader>wJ", "<C-w>J", { desc = "Move window far bottom" })
vim.keymap.set("n", "<leader>wK", "<C-w>K", { desc = "Move window to far top" })

vim.keymap.set("n", "<leader>bs", "<cmd>w<CR>", { desc = "[B]uffer [S]ave" })
vim.keymap.set("n", "<leader>b[", "<cmd>bp<CR>", { desc = "[B]uffer [P]rev" })
vim.keymap.set("n", "<leader>b]", "<cmd>bn<CR>", { desc = "[B]uffer [N]ext" })

vim.keymap.set("n", "<leader>id", function()
  vim.diagnostic.open_float(nil, {
    scope = "cursor",
  })
end, {
  desc = "[I]nspect [D]iagnostic under cursor",
})

vim.keymap.set("n", "<leader>td", function()
  vim.diagnostic.show(nil, 0, nil, {
    virtual_text = {
      source = "if_many",
      spacing = 2,
      format = function(diagnostic)
        local diagnostic_message = {
          [vim.diagnostic.severity.ERROR] = diagnostic.message,
          [vim.diagnostic.severity.WARN] = diagnostic.message,
          [vim.diagnostic.severity.INFO] = diagnostic.message,
          [vim.diagnostic.severity.HINT] = diagnostic.message,
        }
        return diagnostic_message[diagnostic.severity]
      end,
    },
  })
end, {
  desc = "[T]oggle [D]iagnostics (virtual text)",
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("ruff")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("ts_ls")
vim.lsp.enable("eslint")
vim.lsp.enable("rubocop")

require("config.lazy")
