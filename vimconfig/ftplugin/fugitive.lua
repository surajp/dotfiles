-- Fugitive keymaps

local opts = { buffer = 0 }
vim.keymap.set("n","<leader>p","<cmd>G push<CR>",opts)
vim.keymap.set("n","<leader>pf",":G pushf",opts)
vim.keymap.set("n","<leader>l","<cmd>G pull<CR>",opts)
vim.keymap.set("n","<leader>f","<cmd>G fetch<CR>",opts)
vim.keymap.set("n","<leader>fp","<cmd>G fetch --prune<CR>",opts)
vim.keymap.set("n","<leader>o","<cmd>G log<CR>",opts)
