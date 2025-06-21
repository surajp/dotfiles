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
--

vim.api.nvim_create_user_command('FormatJson', function()
  local current_file = vim.fn.expand('%')
  if current_file == '' then
    vim.notify('No file open', vim.log.levels.ERROR)
    return
  end
  
  local cmd = string.format('jq -r . %s > /tmp/rep.json && mv /tmp/rep.json %s', current_file, current_file)
  local result = vim.fn.system(cmd)
  
  if vim.v.shell_error == 0 then
    vim.cmd('edit!') -- Reload the file
    vim.notify('JSON formatted successfully')
  else
    vim.notify('Error formatting JSON: ' .. result, vim.log.levels.ERROR)
  end
end, {
  desc = 'Format JSON file using jq'
})
