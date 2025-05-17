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

require("snipe").setup()

vim.treesitter.query.set("apex","folds"," [ (constructor_declaration) (class_body) (block) (argument_list) (array_initializer) (annotation_argument_list) ] @fold")

vim.cmd("set completeopt+=noselect")

-- lsp
--vim.lsp.enable({'apex_ls'});
