-- Splitting windows
vim.keymap.set("n", "<leader>ws", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wS", "<C-w>s", { desc = "Split window horizontally" })

-- Closing windows
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close the current window" })

-- Switching windows
vim.keymap.set("n", "<leader>wh", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<leader>wl", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<leader>wj", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Moving windows
vim.keymap.set("n", "<leader>wH", "<C-w>H", { desc = "Move window to far left" })
vim.keymap.set("n", "<leader>wL", "<C-w>L", { desc = "Move window to far right" })
vim.keymap.set("n", "<leader>wJ", "<C-w>J", { desc = "Move window to far bottom" })
vim.keymap.set("n", "<leader>wK", "<C-w>K", { desc = "Move window to far top" })
