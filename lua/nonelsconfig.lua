local nonels = require('null-ls')


nonels.setup({
  sources = {
    nonels.builtins.diagnostics.pmd.with({
      extra_args = {
	"-R",
	"rulesets/apex/quickstart.xml",
      },
    }),
  },
  root_dir = function(fname)
    return nonels.util.find_git_ancestor(fname)
  end,
})
