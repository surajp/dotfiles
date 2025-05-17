-- Prevent multiple loading
if vim.g.loaded_copilot_chat_pick_schema then
  return
end

vim.g.loaded_copilot_chat_pick_schema = true

local chat = require("CopilotChat")
local select = require("CopilotChat.select")

-- The Main Picker Function
local function pick_schema_and_chat()
  -- 1. Find all schema files in the current root
  local schemas = vim.fn.glob(".schema/*.d.ts", false, true)

  if #schemas == 0 then
    vim.notify("No .schema/*.d.ts files found!", vim.log.levels.WARN)
    return
  end

  -- 2. Prompt user to select one
  vim.ui.select(schemas, {
    prompt = "Select Salesforce Schema Context:",
    format_item = function(item)
      return "📄 " .. item
    end,
  }, function(choice)
      if not choice then return end
      local resources = {'file:' .. choice}

      -- adding tags file is not working, even manually
      -- local tags_path = vim.fn.getcwd() .. "/tags"
      -- if vim.fn.filereadable(tags_path) == 1 then
      --   table.insert(resources, 'file:tags')
      -- end
      chat.open({sticky="/ApexVibe",resources = resources})
    end
  )
end

vim.api.nvim_create_user_command("CopilotSchemaChat", pick_schema_and_chat, {})

-- Keymap (Optional)
vim.keymap.set({ "n", "v" }, "<leader>ccs", pick_schema_and_chat, { desc = "Pick Schema & Chat" })
