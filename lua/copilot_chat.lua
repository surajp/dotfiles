local cchat = require("CopilotChat")

cchat.setup({
  model = "claude-sonnet-4",
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
