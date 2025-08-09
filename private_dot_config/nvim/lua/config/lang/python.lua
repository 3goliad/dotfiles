Brown:add_dep("ruff")

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  settings = {},
})

vim.lsp.enable("ruff")

require("conform").formatters_by_ft.python = {
  "ruff_fix",
  "ruff_format",
  "ruff_organize_imports",
}
