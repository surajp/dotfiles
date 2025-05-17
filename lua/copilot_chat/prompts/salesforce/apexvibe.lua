return {
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
}
