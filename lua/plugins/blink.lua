return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/my-snippets" })
      	require("luasnip").filetype_extend("apex", { "java" })
      end,
    },
  },
  opts = {
    keymap = {
      preset = "none", -- Don't use any preset
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-h>'] = { 'hide' },
      ['<C-;>'] = { 'select_and_accept' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
    },
    completion = {
      documentation = { auto_show = false }, -- Disable auto-show documentation
      ghost_text = {
      	enabled = false
      }
    },
    snippets = { preset = "luasnip" },
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
