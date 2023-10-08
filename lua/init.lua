local opts = {noremap=true,silent=true}

require("oil").setup({
  keymaps={
    ["<C-p>"]=":Files!<CR>"
  }
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
