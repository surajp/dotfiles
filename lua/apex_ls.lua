local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("apex_ls", {
  cmd = {
    "java", 
    "-cp", 
    "/Users/surajpillai/lib/apex-jorje-lsp.jar",
    "-Dlwc.typegeneration.disabled=true",
    "-Ddebug.semantic.errors=false",
    "-XX:+UseZGC",
    "-Ddebug.internal.errors=true",
    "apex.jorje.lsp.ApexLanguageServerLauncher"
  },
  name = "apex_ls",
  filetypes = { "apex" },
  capabilities = capabilities,
  root_markers = { "sfdx-project.json"},
})

vim.lsp.enable("apex_ls")
