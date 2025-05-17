local function run_current_line_shell()
  local line = vim.api.nvim_get_current_line()
  if line == "" then
    return
  end

  vim.cmd("RunAsyncShell " .. line)
end

vim.keymap.set("n", "<leader>sh", run_current_line_shell, { desc = "Run current line as shell command in temp buffer" })
