local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if not configs.copilot_ls then
  configs.copilot_ls = {
    default_config = {
      cmd = { 'copilot-language-server', '--stdio' },
      name='copilot_ls',
      single_file_support=true,
      autostart=true,
      filetypes = { 'apex' },
      root_dir = function(fname)
	return lspconfig.util.find_git_ancestor(fname)
      end,
      settings={}
    },
  }
end
