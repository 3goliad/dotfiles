-- Splitting windows
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split horizontally" })

-- Closing windows
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close window" })

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
