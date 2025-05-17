local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

vim.lsp.config("ast-grep", {
  cmd = {
    "ast-grep",
    "lsp",
  },
  name = "ast_grep",
  filetypes = { "apex","lwc","javascript","typescript" },
  capabilities = capabilities,
  root_markers = { "sgconfig.yaml"},
})

vim.lsp.enable("ast-grep")
