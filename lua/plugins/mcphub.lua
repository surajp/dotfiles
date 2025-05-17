-- configured as per https://ravitemer.github.io/mcphub.nvim/extensions/copilotchat.html
return {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function()
        require("mcphub").setup({
	  shutdown_delay = 2000, -- milliseconds
	  extensions = {
	    copilotchat = {
	      enabled = true,
	      convert_tools_to_functions = true,
	      convert_resources_to_functions = true,
	      add_mcp_prefix = false,
	    },
	  }
	})
    end
}
