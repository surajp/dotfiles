-- oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", "<CMD>Detour<CR><CMD>Oil<CR>", { desc = "Open parent directory" })

-- hop
local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})
vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})
vim.keymap.set("n", "<leader>hw", function()
	hop.hint_words()
end, {remap=true})


-- buffer nav
local snipe = require("snipe")
vim.keymap.set("n", "gb", function()
  snipe.open_buffer_menu()
end, { remap = false,desc = "Open buffer menu" })

-- timespent
vim.keymap.set("n","<leader>ts","<CMD>ShowTimeSpent<CR>",{desc="Show Time Spent"})

--copilot chat
vim.keymap.set("n","<leader>c","<CMD>CopilotChatOpen<CR>",{desc="Open Copilot Chat"})
vim.keymap.set("n", "<leader>ci", "<Cmd>tabnew .github/copilot-instructions.md<CR>",{desc="Open copilot instructions"}) -- Edit init.lua


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
