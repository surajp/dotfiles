local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

-- Register custom server if not already defined
if not configs.lwc_ls then
  configs.lwc_ls = {
    default_config = {
      cmd = {
        "lwc-language-server",
        "--stdio"
      },
      name = "lwc_ls",
      single_file_support = true,
      autostart = true,
      filetypes = { "html","lwc", "javascript", "typescript" },
      root_dir = lspconfig.util.root_pattern("sfdx-project.json", ".git"),
      settings = {},
    }
  }
end

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


-- Launch the LSP
lspconfig.lwc_ls.setup {
  on_attach = function(client, bufnr)
  end,
  capabilities = capabilities,
}

