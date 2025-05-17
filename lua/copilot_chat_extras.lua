local windowConfig = {
      	layout = 'float',
	relative = 'cursor',
        title = '🤖 AI Quick Chat',
      	width = 1,
      	height = 0.6,
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
    local cchat = require("CopilotChat")
    cchat.reset()
    cchat.setup({
      model = 'gpt-5.1-codex-mini',
      sticky = {
	'@models using gpt-5.1-codex-mini',
	'#buffer'
      },
    })
    local prompt = 'You are a helpful AI assistant specialized in code-related tasks. User is wanting to  have a quick chat about code snippets or programming concepts. Provide concise and relevant answers. The user asks the following question:\n"' .. input .. '"'
    local success, err = pcall(function()
      cchat.ask('#selection '..prompt, {
        window = windowConfig,
      })
    end)
    if not success then
      vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end, { desc = "CopilotChat - Quick chat" })

vim.keymap.set({'n','v'}, '<leader>ccm', function()
    local cchat = require("CopilotChat")
    local success, err = pcall(function()
      cchat.reset()
      cchat.setup({
      	model = 'grok-code-fast-1',
      	selection = {'#selection'},
	sticky={
	  '@Salesforce',
	  'using grok-code-fast-1',
	  '#buffer'
      	},
      })
      cchat.open()
    end)
    if not success then
      vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "CopilotChat - MCP chat" })

vim.keymap.set({'n','v'}, '<leader>ccc', function()
    local cchat = require("CopilotChat")
    local success, err = pcall(function()
      cchat.setup({
      	model = 'claude-sonnet-4.5',
      	selection = {'#selection'},
	sticky={
	  'using claude-sonnet-4.5',
	  '#buffer'
      	},
      })
      cchat.open()
    end)
    if not success then
      vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "CopilotChat - Standard chat" })
