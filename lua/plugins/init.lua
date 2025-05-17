local function load_plugins()
  local plugins = {}
  local plugin_files = vim.fn.glob(vim.fn.stdpath('config') .. '/lua/plugins/config/*.lua', false, true)

  for _, file in ipairs(plugin_files) do
    local plugin_name = vim.fn.fnamemodify(file, ':t:r')
    local plugin_config = require('plugins.config.' .. plugin_name)
    table.insert(plugins, plugin_config)
  end

  return plugins
end


if _G.loaded_plugins then
  return
end

_G.loaded_plugins = load_plugins()

require('lazy').setup(_G.loaded_plugins)
