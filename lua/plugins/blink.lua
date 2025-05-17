return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      version = 'v2.*',
      build = "make install_jsregexp",
      config = function()
        local ls = require("luasnip")
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load({ paths = {vim.fn.expand("$HOME") .. "/.vim/snipmatesnippets"} })
      	ls.filetype_extend("apex", { "java" })
      	ls.filetype_extend("lwc", { "js" })
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
      ['<C-l>'] = { 'snippet_forward','fallback' },
      ['<C-j>'] = { 'snippet_backward','fallback' },
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
