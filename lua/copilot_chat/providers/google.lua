-- we are not loading this module for now since we are going via openrouter. This module is untested.
local gemini_api_key = vim.fn.trim(vim.fn.system("echo $GEMINI_API_KEY 2>/dev/null"))

local gemini = {
	get_url = function(options)
		local model_id = options.model.id:match("^gemini/(.+)$") or options.model.id
		return string.format(
			"https://generativelanguage.googleapis.com/v1beta/models/%s:streamGenerateContent?key=%s",
			model_id,
			gemini_api_key
		)
	end,
	get_headers = function()
		return {
			["Content-Type"] = "application/json",
		}
	end,
	get_models = function()
		return {
			{ id = "gemini/gemini-3-flash-preview",   name = "Gemini 3 Flash Preview" },
			{ id = "gemini/gemini-flash-lite-latest", name = "Gemini Flash Lite Latest" },
			{ id = "gemini/gemini-flash-latest",      name = "Gemini Flash Latest" },
			{ id = "gemini/gemini-3-pro-preview",     name = "Gemini 3 Pro Preview" },
		}
	end,
	prepare_input = function(message, options)
		-- Convert from OpenAI-style messages to Gemini format
		local contents = {}
		local system_instruction = nil

		-- Extract system message if present
		if message[1] and message[1].role == "system" then
			system_instruction = {
				parts = {
					{ text = message[1].content }
				}
			}
			-- Remove system message from contents
			table.remove(message, 1)
		end

		-- Convert remaining messages to Gemini format
		for _, msg in ipairs(message) do
			local role = msg.role
			if role == "assistant" then
				role = "model"
			end

			table.insert(contents, {
				role = role,
				parts = {
					{ text = msg.content }
				}
			})
		end

		local input = {
			contents = contents,
			generationConfig = {
				temperature = options.temperature or 0.7,
			}
		}

		-- Add thinking config for supported models
		local model_id = options.model.id:match("^gemini/(.+)$") or options.model.id
		if model_id == "gemini-3-flash-preview" then
			input.generationConfig.thinkingConfig = {
				thinkingLevel = "MINIMAL"
			}
		end

		if system_instruction then
			input.systemInstruction = system_instruction
		end

		return input
	end,
	prepare_output = function(response, options)
		-- Convert Gemini response to OpenAI-compatible format
		local output = {
			content = "",
			finish_reason = nil
		}

		if response.candidates and response.candidates[1] then
			local candidate = response.candidates[1]
			if candidate.content and candidate.content.parts then
				for _, part in ipairs(candidate.content.parts) do
					if part.text then
						output.content = output.content .. part.text
					end
				end
			end
			output.finish_reason = candidate.finishReason
		end

		return output
	end,
}

return gemini
