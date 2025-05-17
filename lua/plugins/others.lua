return {
  -- Core / UI
  { 'nvim-lua/plenary.nvim', name = 'plenary' }, -- Dependency for many plugins
  -- Utility / Editing Enhancements
  { 'tpope/vim-surround' },
  { 'SirVer/ultisnips', dependencies = { 'honza/vim-snippets' } },
  -- { 'unblevable/quick-scope' }, -- Highlight f/F/t/T targets
  { 'mbbill/undotree' },
  { 'leath-dub/snipe.nvim', config = true }, -- Buffer navigation enhancement

  -- LSP / Completion / Linting / Formatting
  { 'ncm2/float-preview.nvim' }, -- Preview window
  { 'nvimtools/none-ls.nvim'},

  -- Git
  { 'tpope/vim-fugitive' },

  -- Language Specific
  -- { 'dart-lang/dart-vim-plugin' },
  -- { 'pangloss/vim-javascript' }, -- Basic JS syntax (might be superseded by treesitter)
  { 'rust-lang/rust.vim' },

  { 'stevearc/aerial.nvim', dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, config = true }, -- LSP/TreeSitter symbol outline
  -- { 'smoka7/hop.nvim', version = "*", config = function() require('hop').setup() end }, -- EasyMotion replacement
  { 'carbon-steel/detour.nvim', config = true }, -- Run commands in external windows/popups

  { "L3MON4D3/LuaSnip", version = "2.*", dependencies = { "rafamadriz/friendly-snippets" } },

}
