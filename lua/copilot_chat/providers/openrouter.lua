local openrouter_api_key = vim.fn.trim(vim.fn.system("pass openrouter/m3key 2>/dev/null"))

local openrouter = {
	get_url = function()
		return "https://openrouter.ai/api/v1/chat/completions"
	end,
	get_headers = function()
		return {
			["Authorization"] = "Bearer " .. openrouter_api_key,
			["Content-Type"] = "application/json",
			["HTTP-Referer"] = "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
			["X-Title"] = "neovim-copilot-chat",
		}
	end,
	get_models = function()
		return {
			{ id = "openrouter/openrouter/auto",                         name = "Openrouter auto model" },
			{ id = "openrouter/mistralai/devstral-2512",                 name = "Devstral 2" },
			{ id = "openrouter/mistralai/mistral-large-2512",            name = "Mistral Large 3" },
			{ id = "openrouter/anthropic/claude-sonnet-4.5",             name = "Claude Sonnet 4.5" },
			{ id = "openrouter/openai/gpt-5.2",                          name = "GPT 5.2" },
			{ id = "openrouter/openai/gpt-5-mini",                       name = "GPT 5 mini" },
			{ id = "openrouter/openai/gpt-5-nano",                       name = "GPT 5 nano" },
			{ id = "openrouter/openai/gpt-5.3-codex",                    name = "GPT 5.3 Codex" },
			{ id = "openrouter/openai/gpt-5.2-chat",                     name = "GPT 5.2 Chat" },
			{ id = "openrouter/openai/gpt-5.1-codex-max",                name = "GPT 5.1 Codex Max" },
			{ id = "openrouter/openai/gpt-5.2-pro",                      name = "GPT 5.2 Pro" },
			{ id = "openrouter/openai/gpt-oss-120b",                     name = "GPT OSS 120b" },
			{ id = "openrouter/deepseek/deepseek-v3.2",                  name = "Deepseek V3.2" },
			{ id = "openrouter/qwen/qwen3-coder-next",                   name = "Qwen 3 Coder Next" },
			{ id = "openrouter/nvidia/llama-3.1-nemotron-ultra-253b-v1", name = "NVIDIA: Llama 3.1 Nemotron Ultra 253B" },
			{ id = "openrouter/moonshotai/kimi-k2.5",                    name = "Moonshot AI:Kimi K2.5" },
			{ id = "openrouter/moonshotai/kimi-k2-thinking",             name = "Moonshot AI:Kimi K2 Thinking" },
			{ id = "openrouter/google/gemini-3-flash-preview",           name = "Google Gemini 3 Flash Preview" },
			{ id = "openrouter/google/gemini-2.5-flash-lite",            name = "Google Gemini 2.5 Flash Lite" },
			{ id = "openrouter/z-ai/glm-5",                              name = "Z.AI: GLM 5" },
			{ id = "openrouter/z-ai/glm-4.7-flash",                      name = "Z.AI: GLM 4.7 Flash" },
			{ id = "openrouter/minimax/minimax-m2.5",                    name = "Minimax:Minimax M2.5" },
		}
	end,
	prepare_input = function(message, options)
		local input = require('CopilotChat.config.providers').copilot.prepare_input(message, options)
		input.model = options.model.id:match("^openrouter/(.+)$") or options.model.id
		input.stream = true
		if input.model == "google/gemini-3-flash-preview" then
			input.generationConfig = {
				thinkingConfig = { thinkingLevel = "MINIMAL" }
			}
		end
		return input
	end,
	prepare_output = function(response, options)
		local output = require('CopilotChat.config.providers').copilot.prepare_output(response, options)
		if response.choices and response.choices[1] and response.choices[1].finish_reason == "stop" then
			local resolvedModel = response and response.model or 'unknown'
			local resolvedProvider = response and response.provider or 'unknown'
			output.content = output.content .. string.format('\n\nModel: %s', resolvedModel)
			output.content = output.content .. string.format('  Provider: %s', resolvedProvider)
		end
		return output
	end,
}

return openrouter
