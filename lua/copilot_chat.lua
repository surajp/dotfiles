local cchat = require("CopilotChat")

cchat.setup({
  model = "gpt-5",
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
    '@models using gpt-5',
    '#buffer',
  }
})
