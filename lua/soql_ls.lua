local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- capabilities.textDocument.completion.completionItem.resolveSupport = {
--   properties = {
--     'documentation',
--     'detail',
--     'additionalTextEdits',
--   },
-- }

capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

local soql_cmd = {
  "node",
  "/opt/homebrew/lib/node_modules/@salesforce/soql-language-server/lib/server.js",
  "--stdio"
}

vim.lsp.config("soql_ls", {
    cmd = soql_cmd,
  name = "soql_ls",
  filetypes = { "soql" },
  capabilities = capabilities,
  root_markers = { "sfdx-project.json" },
})

vim.lsp.enable("soql_ls")
