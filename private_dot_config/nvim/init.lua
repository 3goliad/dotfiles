require("config.brown")

-- keymaps and typing
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.timeoutlen = 400
vim.o.confirm = true
-- display
vim.g.have_nerd_font = true
vim.o.updatetime = 350
vim.o.number = true
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.cursorline = true
vim.o.scrolloff = 10
-- state and history
vim.o.undofile = true
vim.opt.messagesopt = { "hit-enter", "history:2000" }
-- formatting
vim.o.breakindent = true
vim.o.fixendofline = false -- this is causing odd issues in diffs
-- searching
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"
-- windows
vim.o.splitright = true
vim.o.splitbelow = true

vim.diagnostic.config({
  underline = true,
  -- underline = { severity = vim.diagnostic.severity.ERROR },
  severity_sort = true,
  virtual_lines = { current_line = true },
  -- float = { border = "rounded", source = "if_many" },
  -- signs = vim.g.have_nerd_font and {
  --   text = {
  --     [vim.diagnostic.severity.ERROR] = "󰅚 ",
  --     [vim.diagnostic.severity.WARN] = "󰀪 ",
  --     [vim.diagnostic.severity.INFO] = "󰋽 ",
  --     [vim.diagnostic.severity.HINT] = "󰌶 ",
  --   },
  -- } or {},
  -- virtual_text = {
  --   source = "if_many",
  --   spacing = 2,
  --   format = function(diagnostic)
  --     local diagnostic_message = {
  --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
  --       [vim.diagnostic.severity.WARN] = diagnostic.message,
  --       [vim.diagnostic.severity.INFO] = diagnostic.message,
  --       [vim.diagnostic.severity.HINT] = diagnostic.message,
  --     }
  --     return diagnostic_message[diagnostic.severity]
  --   end,
  -- },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("yank-highlighting", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

Brown.keymaps:add({ "<Esc>", "<cmd>nohlsearch<CR>" })
Brown.keymaps:add({
  "<leader>q",
  vim.diagnostic.setloclist,
  desc = "Open diagnostic [Q]uickfix list",
})
Brown.keymaps:add({
  mode = "t",
  "<Esc><Esc>",
  "<C-\\><C-n>",
  desc = "Exit terminal mode",
})
Brown.keymaps.w:add(
  -- Splitting windows
  { "v", "<C-w>v", desc = "[W]indow [V]ertical Split" },
  { "s", "<C-w>s", desc = "[W]indow [H]orizontal Split" },
  -- Closing windows
  { "c", "<C-w>c", desc = "[W]indow [C]lose" },
  -- Switching windows
  { "h", "<C-w><C-h>", desc = "Focus left window" },
  { "l", "<C-w><C-l>", desc = "Focus right window" },
  { "j", "<C-w><C-j>", desc = "Focus lower window" },
  { "k", "<C-w><C-k>", desc = "Focus upper window" },
  -- Moving windows
  { "H", "<C-w>H", desc = "Move window far left" },
  { "L", "<C-w>L", desc = "Move window far right" },
  { "J", "<C-w>J", desc = "Move window far bottom" },
  { "K", "<C-w>K", desc = "Move window to far top" }
)
Brown.keymaps.b:add(
  { "s", "<cmd>w<CR>", desc = "[B]uffer [S]ave" },
  { "k", "<cmd>q<CR>", desc = "[B]uffer [K]ill" },
  { "[", "<cmd>bp<CR>", desc = "[B]uffer [P]rev" },
  { "]", "<cmd>bn<CR>", desc = "[B]uffer [N]ext" }
)

vim.lsp.enable("lua_ls")
vim.lsp.enable("ruff")

require("config.lazy")
