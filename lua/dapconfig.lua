require('dapui').setup()

local dap = require('dap')

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command= "node",
    args = {os.getenv("HOME") .. "/softwares/dapservers/js-debug/src/dapDebugServer.js","${port}"},
  }
}

require('dap-python').setup(os.getenv('HOME') .. '/softwares/dapservers/python-debugpy/bin/python')

dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.typescript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = "Launch file",
    runtimeExecutable = "deno",
    runtimeArgs = {
      "run",
      "--inspect-wait",
      "--allow-all"
    },
    program = "${file}",
    cwd = "${workspaceFolder}",
    attachSimplePort = 9229,
  },
}
