require("config.settings")

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, {
    desc = desc,
  })
end

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
nmap_leader("q", vim.diagnostic.setloclist, "Open diagnostic [Q]uickfix list")

-- Diagnostics
nmap_leader("id", function()
  vim.diagnostic.open_float(nil, {
    scope = "cursor",
  })
end, "[I]nspect [D]iagnostic under cursor")

nmap_leader("td", function()
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
end, "[T]oggle [D]iagnostics (virtual text)")

-- Custom LSP configs
vim.lsp.enable("typescript_lsp")

vim.pack.add({
  {
    src = "https://github.com/neovim/nvim-lspconfig",
    version = "v2.9.0",
  },
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/esmuellert/codediff.nvim" },
})

vim.cmd.colorscheme("jawbreaker")

vim.lsp.enable("lua_ls")
vim.lsp.enable("ruff")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("eslint")
vim.lsp.enable("ruby_lsp")
vim.lsp.enable("rubocop")

require("mini.extra").setup()
require("mini.pairs").setup()
require("mini.misc").setup()
require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })

require("mini.trailspace").setup()
nmap_leader("bt", function()
  MiniTrailspace.trim()
  MiniTrailspace.trim_last_lines()
end, "[T]rim trailing whitespace")

require("mini.bufremove").setup()
nmap_leader("bk", MiniBufremove.delete, "[B]uffer [K]ill")

require("mini.files").setup()
nmap_leader("ff", function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, "Browse at this [f]ile")
nmap_leader("fl", MiniFiles.open, "Open [l]ast file browser")

require("mini.ai").setup({ n_lines = 500 })

require("mini.surround").setup()

require("mini.splitjoin").setup()

local hi_words = MiniExtra.gen_highlighter.words
require("mini.hipatterns").setup({
  highlighters = {
    fixme = hi_words({ "FIXME" }, "MiniHipatternsFixme"),
    hack = hi_words({ "HACK" }, "MiniHipatternsHack"),
    todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
    note = hi_words({ "NOTE" }, "MiniHipatternsNote"),
  },
})

local miniclue = require("mini.clue")
miniclue.setup({
  window = {
    width = "auto",
  },
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    -- { mode = 'i', keys = '<C-x>' },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = { "n", "x" }, keys = "z" },
  },
  clues = {
    { mode = "n", keys = "<Leader>b", desc = "[B]uffer" },
    { mode = "n", keys = "<Leader>s", desc = "[S]earch" },
    { mode = "n", keys = "<Leader>g", desc = "[G]it" },
    { mode = "n", keys = "<Leader>f", desc = "[F]ile" },
    { mode = "n", keys = "<Leader>t", desc = "[T]oggle" },
    { mode = "n", keys = "<Leader>i", desc = "[I]nspect" },
    miniclue.gen_clues.square_brackets(),
    -- miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})

local win_config = function()
  local height = math.floor(0.8 * vim.o.lines)
  local width = math.floor(0.8 * vim.o.columns)
  return {
    anchor = "NW",
    height = height,
    width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end
require("mini.pick").setup({
  window = { config = win_config },
  mappings = {
    choose_all_as_marked = {
      char = "<C-q>",
      func = function()
        local opts = MiniPick.get_picker_opts()
        if not opts then
          return false
        end

        local ok, res =
          pcall(opts.source.choose_marked, MiniPick.get_picker_matches().all)

        if not ok then
          vim.schedule(function()
            error("(mini.pick) Error during choose marked:\n" .. res, 0)
          end)
        end

        return not (ok and res)
      end,
    },
  },
})
nmap_leader(" ", MiniPick.builtin.files, "[ ] Search files")
nmap_leader("sg", MiniPick.builtin.grep_live, "Live [g]rep search")
nmap_leader("sb", function()
  MiniExtra.pickers.buf_lines({ scope = "current" })
end, "Search [b]uffer")
nmap_leader("sh", MiniPick.builtin.help, "Search [h]elp")
nmap_leader("bb", MiniPick.builtin.buffers, "[B]ounce to buffer")

require("lazydev").setup({
  library = {
    -- See the configuration section for more details
    -- Load luvit types when the `vim.uv` word is found
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

require("blink.cmp").setup(require("config.settings-blink"))

-- Formatting
local conform = require("conform")

conform.setup(require("config.settings-conform"))

nmap_leader("bf", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, "[F]ormat buffer")

-- Toggleterm
require("toggleterm").setup({
  open_mapping = "<C-\\>",
  direction = "float",
  float_opts = {
    border = "rounded",
  },
})

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {
  desc = "Exit terminal mode",
})

-- Fugitive
nmap_leader("gg", "<cmd>tab Git<CR>", "Open Fu[g]itive")
nmap_leader("gB", "<cmd>Git blame<CR>", "Git [b]lame buffer")
nmap_leader("gL", "<cmd>vertical Git log --oneline %<CR>", "Git [l]og buffer")

-- Codediff
require("codediff").setup({
  explorer = { position = "bottom" },
})

-- Vitest
require("vitest").setup()
