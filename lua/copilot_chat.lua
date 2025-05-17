local cchat = require("CopilotChat")

cchat.setup({
  model = "claude-3.7-sonnet",
  context = "file:.github/copilot-instructions.md",
  chat_autocomplete = false,
  mappings = {
    complete = {
      insert = "<Tab>"
    },
    reset = {
      normal = '<C-l>',
      insert = '<C-l>',
    },
  }
})
