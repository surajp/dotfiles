require("oil").setup({
  keymaps={
    ["<C-p>"]=":Files!<CR>",
    ["<C-i>"]="actions.preview"
  }
})

require('hop').setup()
vim.cmd('hi HopNextKey guifg=#c2c52d')
vim.cmd('hi HopNextKey1 guifg=#c2c52d')
vim.cmd('hi HopNextKey2 guifg=#c2c52d')
