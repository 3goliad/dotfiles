---@module "blink.cmp"
---@type blink.cmp.Config
return {
  keymap = {
    preset = "super-tab",
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    trigger = {
      show_in_snippet = false,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "lazydev" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
}
