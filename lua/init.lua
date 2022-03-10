local opts = {noremap=true,silent=true}

vim.api.nvim_set_keymap('i','jk','<Esc>',opts)
vim.api.nvim_set_keymap('i','kj','<Esc>',opts)
vim.api.nvim_set_keymap('n','<C-f>l',':Helptags!<CR>',opts)
