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
vim.o.signcolumn = "number"
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
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
