local pplx_api_key = vim.fn.trim(vim.fn.system("pass pplx/85suraj/visidata 2>/dev/null"))

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
			{ id = "sonar",               name = "Perplexity Sonar" },
			{ id = "sonar-pro",           name = "Perplexity Sonar Pro" },
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
		input.stream = true
		return input
	end,
	prepare_output = function(response, options)
		-- Debug: Print the entire response structure
		vim.notify("Full response: " .. vim.inspect(response), vim.log.levels.INFO)

		-- Check if response is valid
		if type(response) == "string" then
			vim.notify("Response is a string (possibly HTML error): " .. response:sub(1, 100), vim.log.levels.ERROR)
			return { content = "" }
		end

		local output = require('CopilotChat.config.providers').copilot.prepare_output(response, options)

		-- Safely access nested fields
		if response.choices and response.choices[1] and response.choices[1].delta then
			output.content = response.choices[1].delta.content or ""
		else
			output.content = ""
		end

		if response.object == "chat.completion.done" and not options.done then
			output.content = output.content .. '\n\n\n### Web Results:'
			for _, search in ipairs(response.search_results or {}) do
				output.content = output.content .. string.format('\n[%s] [%s](%s)', search.date, search.title, search.url)
			end
			options.done = true
		end
		return output
	end,
}
