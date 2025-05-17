return {
  { 'github/copilot.vim' },
  {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  dependencies = {
    { "github/copilot.vim" }, -- Must be loaded first or same lazy load event
    { "nvim-lua/plenary.nvim" }, -- Required for tests
  },
  config = function()
    require("CopilotChat").setup { }
  end,
  }
}
