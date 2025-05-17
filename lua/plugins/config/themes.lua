-- Color themes and othe ui enhancements
return {
  { 'vim-airline/vim-airline' },
  { 'vim-airline/vim-airline-themes' },
  { 'gruvbox-community/gruvbox', lazy = true }, -- Load only when called
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 }, -- High priority for colorscheme
  { 'cocopon/iceberg.vim', lazy = true },
  { 'aliqyan-21/darkvoid.nvim', lazy = true },
  { 'HiPhish/rainbow-delimiters.nvim', config = function() require("rainbow-delimiters.setup").setup() end },

}
