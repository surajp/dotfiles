local lspconfig = require("lspconfig")

local soql_cmd = {
  "node",
  "/opt/homebrew/lib/node_modules/@salesforce/soql-language-server/lib/server.js",
  "--stdio"
}

lspconfig.soql_ls = {
  default_config = {
    cmd = soql_cmd,
    filetypes = { "soql", "apex"},
    root_dir = lspconfig.util.root_pattern("sfdx-project.json"),
  },
}
