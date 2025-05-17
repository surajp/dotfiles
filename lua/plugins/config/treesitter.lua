return {
  "nvim-treesitter/nvim-treesitter",
  build = ':TSUpdate',
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = {"java","apex","json","csv","javascript","bash","lua","vim","comment","markdown","soql","sosl","sflog", "rust", "python", "html", "css", "typescript"}, -- Added more common languages
      sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
      auto_install = true, -- Automatically install missing parsers when entering buffer
      ignore_install = {}, -- List of parsers to ignore installing
      highlight = {
        enable = true,              -- false will disable the whole extension
        disable = {},  -- list of language that will be disabled
        additional_vim_regex_highlighting = false -- Keep this false unless needed
      },
      indent = { enable = true }, -- Enable TreeSitter based indentation
      -- Other modules can be enabled here, e.g., textobjects
    }
  end,
  opts_extend = { "sources.default" }
}
