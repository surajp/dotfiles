local pplx_api_key = vim.fn.trim(vim.fn.system("pass pplx/85suraj/visidata"))

return {
  get_url = function()
    return "https://api.perplexity.ai/chat/completions"
  end,
  get_headers = function()
    return {
      ["Authorization"] = "Bearer " .. pplx_api_key,
      ["Content-Type"] = "application/json",
      ["HTTP-Referer"] = "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
    }
  end,
  get_models = function()
    return {
      { id = "sonar", name = "Perplexity Sonar" },
      { id = "sonar-pro", name = "Perplexity Sonar Pro" },
      { id = "sonar-reasoning-pro", name = "Perplexity Sonar Reasoning Pro" },
    }
  end,
  prepare_input = function(message, options)
    local input = require('CopilotChat.config.providers').copilot.prepare_input(message, options)
    local fix_messages = {}
    for _, msg in ipairs(input.messages) do
      if #fix_messages > 0 and msg.role == "user" and fix_messages[#fix_messages].role == "user" then
	table.insert(fix_messages, { role = "assistant", content = "" })
      elseif #fix_messages > 0 and msg.role == "assistant" and fix_messages[#fix_messages].role == "assistant" then
	table.insert(fix_messages, { role = "user", content = "" })
      end
      table.insert(fix_messages, msg)
    end
    input.messages = fix_messages
    input.stream = false
    return input
  end,
  prepare_output = function(response, options)
    local output = require('CopilotChat.config.providers').copilot.prepare_output(response, options)
    output.content = output.content .. '\n\nSearch Results:'
    for _, search in ipairs(response.search_results or {}) do
      output.content = output.content .. string.format('\n[%s] [%s](%s)', search.date, search.title, search.url)
    end
    return output
  end,
}
