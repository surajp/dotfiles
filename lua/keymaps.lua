-- oil
vim.keymap.set("n", "-", function() require("oil").open() end, { desc = "Open parent directory" })
-- vim.keymap.set("n", "<leader>-", "<CMD>Detour<CR><CMD>Oil<CR>", { desc = "Open parent directory" })



-- buffer nav
local snipe = require("snipe")
vim.keymap.set("n", "gb", function()
  snipe.open_buffer_menu()
end, { remap = false,desc = "Open buffer menu" })

--copilot chat
vim.keymap.set("n","<leader>cc","<CMD>CopilotChatOpen<CR>",{desc="Open Copilot Chat"})


-- dap keymaps
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "Open REPL" })
vim.keymap.set("n", "<leader>ds", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function() require("dap").step_out() end, { desc = "Step Out" })
vim.keymap.set('n', '<Leader>dlp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)


-- add to quickfix list
vim.api.nvim_set_keymap('n', '<leader>aq', [[:lua vim.fn.setqflist({{filename = vim.fn.expand('%'), lnum = vim.fn.line('.'), col = vim.fn.col('.'), text = 'Custom issue description'}}, 'a')<CR>]], { noremap = true, silent = true })


-- vim.keymap.set("i", "<C-CR>", function()
--   if not vim.lsp.inline_completion.get() then
--     return "<C-CR>"
--   end
-- end, {
--   expr = true,
--   replace_keycodes = true,


-- timesheet
vim.keymap.set("n", "<leader>ts", function()
  local today = os.date("%m-%y")
  vim.cmd(string.format("tabnew ~/timesheets/%s.md", today))
end, { desc = "Open Timesheet" })
