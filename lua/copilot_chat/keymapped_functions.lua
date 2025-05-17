-- Window configuration for floating CopilotChat windows
local windowConfig = {
  layout = 'float',      -- Floating window layout
  relative = 'cursor',   -- Position relative to cursor
  title = '🤖 AI Quick Chat', -- Window title
  width = 1,             -- Width as ratio of screen (1 = full width)
  height = 0.6,          -- Height as ratio of screen (0.6 = 60%)
  row = 1                -- Row offset from cursor
}
-- If CopilotChat is not installed, notify user and exit
local ok = pcall(require, "CopilotChat")
if not ok then
  vim.notify("CopilotChat plugin not available", vim.log.levels.WARN)
  return
end

-- Usage: <leader>ccq in normal or visual mode
-- Features:
-- - Uses gpt-5.1-codex-mini model
-- - Sticky context for quick chat mode
-- - Floating window positioned relative to cursor
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

-- MCP Chat: Specialized chat with Salesforce MCP server enabled
-- Usage: <leader>ccm in normal or visual mode
-- Features:
-- - Uses grok-code-fast-1 model optimized for Salesforce
-- - Pre-configured sticky context for Salesforce MCP mode
-- - Opens in default CopilotChat window
vim.keymap.set({'n','v'}, '<leader>ccm', function()
    local cchat = require("CopilotChat")
    local model = 'grok-code-fast-1'
    local success, err = pcall(function()
      cchat.setup({
        model = model,
        selection = {'#selection'},
        sticky={
          'Assistant with Salesforce MCP mode',
          '@Salesforce',
          'using '..model,
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

-- Usage: <leader>ccc in normal or visual mode
-- Available modes:
-- - Coding Assistant: General coding help
-- - Code Review: Code quality and best practices
-- - Planning & Design: Software architecture and design
-- - Documentation: Writing documentation
-- - Debugging: Bug identification and fixing
-- - Refactoring: Code structure improvements
-- - Testing: Test case development
vim.keymap.set({'n','v'}, '<leader>ccc', function()
    local modes = {
      { name = 'Coding Assistant', sticky = {'coding assistant mode', 'Assist with coding tasks, code generation, and debugging', '#buffer'} },
      { name = 'Code Review', sticky = {'code review mode', 'Focus on code quality, best practices, and potential improvements. Do not write whole code, only snippets or pesuedo code for suggestions, if needed', '#buffer'} },
      { name = 'Planning & Design', sticky = {'planning and design mode', 'Focus on software architecture, design patterns, and system planning.Do not write whole code, only snippets or pesuedo code for suggestions, if needed', '#buffer'} },
      { name = 'Documentation', sticky = {'documentation mode', 'Help with writing clear and comprehensive documentation. Do not write whole code, only snippets or pesuedo code for documentation, if needed', '#buffer'} },
      { name = 'Debugging', sticky = {'debugging mode', 'Help identify and fix bugs in the code. Do not write whole code, only snippets or pesuedo code for explanation as needed', '#buffer'} },
      { name = 'Refactoring', sticky = {'refactoring mode', 'Suggest improvements to code structure and design. Do not write whole code, only snippets or pesuedo code, if needed', '#buffer'} },
      { name = 'Testing', sticky = {'testing mode', 'Help write and improve test cases. Only write testing code, no application or business logic implementations', '#buffer'} },
      { name = 'General Chat', sticky = {'general chat mode', 'General help without additional context'} },
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
          show_citation = true,
        })
        cchat.reset()
        cchat.open()
      end)
      if not success then
        vim.notify("CopilotChat error: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
end, { desc = "CopilotChat - Standard chat" })

-- Usage: <leader>ccs in normal or visual mode
-- Features:
-- - Uses sonar model for web search capabilities
-- - Sticky context for quick web search mode
-- - Opens in floating window
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

-- Usage: <leader>cce in normal or visual mode
-- Features:
-- - Uses gpt-5.1-codex-mini model
-- - Retrieves diagnostic message at cursor position
-- - Provides concise explanation and fix suggestion
-- - Opens in floating window
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
