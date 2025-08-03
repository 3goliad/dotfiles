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
