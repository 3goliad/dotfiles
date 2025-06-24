Private:map_key_group(
  "[W]indow",
  "<leader>w",
  -- Splitting windows
  { "v", "<C-w>v", { desc = "[W]indow [V]ertical Split" } },
  { "s", "<C-w>s", { desc = "[W]indow [H]orizontal Split" } },
  -- Closing windows
  { "c", "<C-w>c", { desc = "[W]indow [C]lose" } },
  -- Switching windows
  { "h", "<C-w><C-h>", { desc = "Focus left window" } },
  { "l", "<C-w><C-l>", { desc = "Focus right window" } },
  { "j", "<C-w><C-j>", { desc = "Focus lower window" } },
  { "k", "<C-w><C-k>", { desc = "Focus upper window" } },
  -- Moving windows
  { "H", "<C-w>H", { desc = "Move window far left" } },
  { "L", "<C-w>L", { desc = "Move window far right" } },
  { "J", "<C-w>J", { desc = "Move window far bottom" } },
  { "K", "<C-w>K", { desc = "Move window to far top" } }
)

Private:map_key_group(
  "[B]uffer",
  "<leader>b",
  { "s", "<cmd>w<CR>", { desc = "[B]uffer [S]ave" } },
  { "k", "<cmd>q<CR>", { desc = "[B]uffer [K]ill" } },
  { "[", "<cmd>bp<CR>", { desc = "[B]uffer [P]rev" } },
  { "]", "<cmd>bn<CR>", { desc = "[B]uffer [N]ext" } }
)

Private:map_key_group(
  "[F]ile",
  "<leader>f",
  { "f", "<cmd>Explore<CR>", { desc = "[F]ile Browser" } }
)
