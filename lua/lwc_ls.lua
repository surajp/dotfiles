
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  },
}
capabilities.workspace = {
  workspaceFolders = {
    supported = true,
    changeNotifications = true,
  }
}

capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

vim.lsp.config("lwc_ls", {
  cmd = {
    "lwc-language-server",
    "--stdio"
  },
  name = "lwc_ls",
  filetypes = { "html","lwc", "javascript", "typescript" },
  root_markers = { "sfdx-project.json"},
})

vim.lsp.enable("lwc_ls")

