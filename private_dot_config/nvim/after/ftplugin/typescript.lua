vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

vim.keymap.set("n", "<leader>mtt", function()
  Vitest.edit_test_or_subject(0)
end, {
  desc = "[T]oggle [T]est file",
  buffer = true,
})
