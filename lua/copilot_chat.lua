local cchat = require("CopilotChat")

cchat.setup({
  model = "claude-sonnet-4",
  context = "file:.github/copilot-instructions.md",
  chat_autocomplete = true,
  mappings = {
    complete = {
      insert = "<C-l>"
    },
    reset = {
      normal = '<C-r>',
      insert = '<C-r>',
    },
  },
  sticky = {
    '@models using claude-sonnet-4',
    '#buffer',
  }
})
