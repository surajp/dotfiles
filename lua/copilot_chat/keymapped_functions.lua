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
    cchat.setup({
      model = 'gpt-5.1-codex-mini',
      sticky = {
      	'Quick chat mode',
	'@models using gpt-5.1-codex-mini',
	'#buffer'
      },
    })
    cchat.reset()
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
      cchat.setup({
      	model = 'grok-code-fast-1',
      	selection = {'#selection'},
	sticky={
	  'Assistant with Salesforce MCP mode',
	  '@Salesforce',
	  'using grok-code-fast-1',
	  '#buffer'
      	},
      })
      cchat.reset()
      cchat.open()
    end)
    if not success then
      vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "CopilotChat - MCP chat" })

vim.keymap.set({'n','v'}, '<leader>ccc', function()
    local modes = {
      { name = 'Coding Assistant', sticky = {'coding assistant mode', 'Assist with coding tasks, code generation, and debugging', '#buffer'} },
      { name = 'Code Review', sticky = {'code review mode', 'Focus on code quality, best practices, and potential improvements', '#buffer'} },
      { name = 'Planning & Design', sticky = {'planning and design mode', 'Focus on software architecture, design patterns, and system planning', '#buffer'} },
      { name = 'Documentation', sticky = {'documentation mode', 'Help with writing clear and comprehensive documentation', '#buffer'} },
      { name = 'Debugging', sticky = {'debugging mode', 'Help identify and fix bugs in the code', '#buffer'} },
      { name = 'Refactoring', sticky = {'refactoring mode', 'Suggest improvements to code structure and design', '#buffer'} },
      { name = 'Testing', sticky = {'testing mode', 'Help write and improve test cases', '#buffer'} },
    }
    local choices = {}
    for _, mode in ipairs(modes) do
      table.insert(choices, mode.name)
    end
    vim.ui.select(choices, {
      prompt = 'Select chat mode:',
    }, function(choice, idx)
      if not choice or not idx then
        return
      end
      local selected_mode = modes[idx]
      local cchat = require("CopilotChat")
      local success, err = pcall(function()
        cchat.setup({
          selection = {'#selection'},
          sticky = selected_mode.sticky,
        })
        cchat.reset()
        cchat.open()
      end)
      if not success then
        vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
end, { desc = "CopilotChat - Standard chat" })

vim.keymap.set({'n','v'}, '<leader>ccs', function()
    local cchat = require("CopilotChat")
    local model = 'sonar'
    local success, err = pcall(function()
      cchat.setup({
      	selection = {'#selection'},
	model = model,
	sticky={
	  'quick web search mode'
      	},
      })
      cchat.reset()
      cchat.open({ window = windowConfig })
    end)
    if not success then
      vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "Perplexity - Quick Search" })

vim.keymap.set({'n','v'}, '<leader>cce', function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local bufnr = vim.api.nvim_get_current_buf()
  local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  if vim.tbl_isempty(diags) then
    vim.notify('No diagnostics at cursor', vim.log.levels.INFO)
    return
  end

  local messages = {}
  for _, d in ipairs(diags) do
    table.insert(messages, d.message)
  end
  local diag_msg = table.concat(messages, '\n---\n')

  local cchat = require('CopilotChat')
  local success, err = pcall(function()
    cchat.setup({
      model = 'gpt-5.1-codex-mini',
      selection = {'#selection'},
      sticky = {
        'Diagnostic explanation mode',
        '#buffer'
      },
    })
    cchat.reset()
    local prompt = 'A diagnostic was reported in the file at line ' .. tostring(cursor[1]) .. ':\n' .. diag_msg .. '\n\nProvide a concise explanation of the root cause and a short, actionable suggestion to fix the code.'
    cchat.ask('#selection '..prompt, { window = windowConfig })
  end)
  if not success then
    vim.notify('CopilotChat error: ' .. tostring(err), vim.log.levels.ERROR)
  end
end, { desc = 'CopilotChat - Explain diagnostic' })
