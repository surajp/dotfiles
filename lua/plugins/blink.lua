return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {"rafamadriz/friendly-snippets"},
  opts = {
    keymap = { 
      preset = "none", -- Don't use any preset
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide' },
      ['<C-y>'] = { 'select_and_accept' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
    },
    completion = {
      documentation = { auto_show = false }, -- Disable auto-show documentation
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "buffer","snippets" }, 
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" }
}
