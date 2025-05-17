local function load_prompts()
	local prompts = {}
	local prompts_dir = vim.fn.stdpath("config") .. "/lua/copilot_chat/prompts"

	-- Use vim.fs.find to recursively find all .lua files
	local files = vim.fs.find(function(name)
		return name:match("%.lua$")
	end, { path = prompts_dir, type = "file", limit = math.huge })

	for _, file in ipairs(files) do
		-- Convert absolute path to module path
		local mod = file:match("lua/(.+)%.lua$")
		if mod then
			mod = mod:gsub("/", ".")
			local ok, module = pcall(require, mod)
			if ok and type(module) == "table" then
				prompts = vim.tbl_extend("force", prompts, module)
			end
		end
	end
	return prompts
end

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		lazy = true,
		event = "VeryLazy",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		config = function()
			local openrouter = require("copilot_chat.providers.openrouter")
			local pplx = require("copilot_chat.providers.perplexity")
			local sfschema = require("copilot_chat.context_functions.sfschema")
			local prompts = load_prompts()
			require("CopilotChat").setup({
				context = "file:.github/copilot-instructions.md",
				chat_autocomplete = true,
				stop_on_function_call = false,
				mappings = {
					complete = {
						insert = "<C-l>",
					},
					reset = {
						normal = "<C-r>",
						insert = "<C-r>",
					},
				},
				sticky = {
					"#buffer",
				},
				prompts = prompts,
				providers = {
					openrouter = openrouter,
					perplexity = pplx,
					ollama = require("copilot_chat.providers.ollama")
				},
				functions = {
					sfschema = sfschema,
					memory = require("copilot_chat.context_functions.memory"),
				}
			})
		end,
	},
}
