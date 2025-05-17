local windowConfig = {
      	layout = 'float',
	relative = 'cursor',
        title = '🤖 AI Quick Chat',
      	width = 1,
      	height = 0.4,
      	row = 1
      };

local ok = pcall(require, "CopilotChat")
if not ok then
  vim.notify("CopilotChat plugin not available", vim.log.levels.WARN)
  return
end

vim.keymap.set({'n','v'}, '<leader>ccq', function()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").reset()
    require("CopilotChat").ask(input, {
      selection = {'#buffer','#selection'},
      model = 'gpt-5-mini',
      sticky = {
      	'using gpt-5-mini',
      },
      window = windowConfig,
    })
  end
end, { desc = "CopilotChat - Quick chat" })

-- no perplexityai agent? 
-- vim.keymap.set({ 'n', 'v' }, '<leader>ccs', function()
--   local input = vim.fn.input("Perplexity: ")
--   if input ~= "" then
--     require("CopilotChat").reset()
--     require("CopilotChat").ask(input, {
--       agent = "perplexityai",
--       selection = {},
--       window = windowConfig
--     })
--   end
-- end, { desc = "CopilotChat - Perplexity Search" })
