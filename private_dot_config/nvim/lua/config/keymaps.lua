vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set(
  "n",
  "<leader>q",
  vim.diagnostic.setloclist,
  { desc = "Open diagnostic [Q]uickfix list" }
)
vim.keymap.set(
  "t",
  "<Esc><Esc>",
  "<C-\\><C-n>",
  { desc = "Exit terminal mode" }
)

vim.g.which_key_specs = {}

function set_keymap_group(desc, prefix, ...)
  table.insert(vim.g.which_key_specs, { prefix, group = desc })
  local arg = { ... }
  for i, m in ipairs(arg) do
    local mapping = prefix .. m[1]
    vim.keymap.set("n", mapping, m[2], m[3])
  end
end

set_keymap_group(
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

set_keymap_group(
  "[B]uffer",
  "<leader>b",
  { "s", "<cmd>w<CR>", { desc = "[B]uffer [S]ave" } },
  { "k", "<cmd>q<CR>", { desc = "[B]uffer [K]ill" } },
  { "[", "<cmd>bp<CR>", { desc = "[B]uffer [P]rev" } },
  { "]", "<cmd>bn<CR>", { desc = "[B]uffer [N]ext" } }
)

set_keymap_group(
  "[F]ile",
  "<leader>f",
  { "f", "<cmd>Explore<CR>", { desc = "[F]ile Browser" } }
)
