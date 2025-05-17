return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local highlight = {
      "RainbowDelimiterRed",
      "RainbowDelimiterYellow",
      "RainbowDelimiterBlue",
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    }
    require("ibl").setup({
      indent = {
    	char = { "▏", "│" },
    	highlight = { "IblIndent" },
    	smart_indent_cap = true,
    	priority = 2,
    	repeat_linebreak = false,
      },
      whitespace = {
    	highlight = { "IblWhitespace", "NonText" },
    	remove_blankline_trail = true,
      },
      scope = {
    	enabled = true,
    	show_start = true,
    	show_end = true,
    	show_exact_scope = false,
    	injected_languages = true,
        highlight = highlight,
    	priority = 1024,
    	include = {
      	  node_type = {
            ["*"] = { "function_definition", "class_definition" },
      	  },
    	},
    	exclude = {
      	  language = { "vim" },
      	  node_type = {
            ["*"] = { "source_file", "program" },
            lua = { "chunk" },
      	  },
    	},
      },
      exclude = {
    	filetypes = {
      	  "help",
      	  "copilot-chat",
      	  "term",
      	  "lazy",
      	  "NvimTree",
      	  "dashboard",
    	},
    	buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    })
  end,
}
