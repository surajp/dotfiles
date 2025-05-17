-- prevent loading this file multiple times
if vim.g.loaded_agent_script then
  return
end
vim.g.loaded_agent_script = true

-- For Salesforce agent script files
vim.filetype.add({
  extension = {
    agent = "yaml",
  },
})

-- Agent Script strictly requires 3-space indentation (unlike standard 2 or 4)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.agent"},
  callback = function(args)
    if vim.fn.expand("%:e") == "agent" then
      vim.bo.shiftwidth = 3
      vim.bo.tabstop = 3
      vim.lsp.buf.format({
      	async = false,
      	bufnr = args.buf,
      	filter = function(client) return client.name == "yamlls" end,
      })
    end
  end,
})
