local ollama = {
  get_url = function()
    return "https://localhost:11434/api/chat/completions"
  end,
  get_headers = function()
    return {
      ["Content-Type"] = "application/json",
    }
  end,
  get_models = function()
    return {
      { id = "ollama/gemma3:12b", name = "Gemma 3 (12B)" },
    }
  end,
  prepare_input = function(message,options)
    local input = require('CopilotChat.config.providers').copilot.prepare_input(message,options)
    input.model = options.model.id:match("^ollama/(.+)$") or options.model.id
    input.stream = true
    return input
  end,
  prepare_output = function(response,options)
    local output = require('CopilotChat.config.providers').copilot.prepare_output(response,options)
    return output
  end,
}

return ollama
