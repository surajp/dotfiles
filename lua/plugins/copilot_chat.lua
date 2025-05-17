return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = false,
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      local openrouter = require("copilot_chat.providers.openrouter")
      local pplx = require("copilot_chat.providers.perplexity")
      local sfschema = require("copilot_chat.context_functions.sfschema")
      require("CopilotChat").setup({
        context = "file:.github/copilot-instructions.md",
        chat_autocomplete = true,
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
        prompts = {
          ApexVibe = {
            system_prompt = [[
	      You are a Salesforce Architect. 
	      1. Use the provided TypeScript Schema as the strict source of truth for SObject fields and relationships.
	      2. Use the Service Layer pattern (Separation of Concerns).
	      3. Always use schema to determine the fields to be queried or manipulated.
	    ]],
            description = "Generate Apex using local schema.d.ts context",
	    selection = function(source)
  	      local select = require("CopilotChat.select")
  	      local visual_selection = select.selection(source) or ""

  	      return string.format(
    		"### USER CODE:\n%s\n\n### SCHEMA CONTEXT (TypeScript Interfaces):\n%s",
    		visual_selection
  	      )
	    end,
          },
        },
  	providers = {
	  openrouter=openrouter,
	  perplexity=pplx,
	},
	functions = {
	  sfschema = sfschema,
	}
      })
    end,
  },
}
