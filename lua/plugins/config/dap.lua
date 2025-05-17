return {
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui', dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
  { 'mfussenegger/nvim-dap-python' }, -- Installs python debugger automatically
}
