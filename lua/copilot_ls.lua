vim.lsp.config("copilot",{
  settings = {
    telemetry = {
      telemetryLevel = "off",
    },
  },
})

vim.lsp.enable("copilot")
