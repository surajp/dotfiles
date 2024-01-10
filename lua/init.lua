require("oil").setup({
  view_options={
    show_hidden=true,
    is_always_hidden = function(name, bufnr)
      return name == ".."
    end
  },
  keymaps={
    ["<C-p>"]=":Files!<CR>",
    ["<C-i>"]="actions.preview"
  }
})

require('hop').setup()
vim.cmd('hi HopNextKey guifg=#c2c52d')
vim.cmd('hi HopNextKey1 guifg=#c2c52d')
vim.cmd('hi HopNextKey2 guifg=#c2c52d')
