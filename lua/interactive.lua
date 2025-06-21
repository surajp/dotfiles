local function run_interactive_command_multi(cmd_template, args_config, notify_prefix)
  return function()
    local current_file = vim.fn.expand('%:p')
    local filename = vim.fn.fnamemodify(current_file, ":t")

    -- Replace standard file placeholders
    cmd_template = cmd_template:gsub("%%:p", current_file)
    cmd_template = cmd_template:gsub("%%", vim.fn.expand('%'))

    -- Process arguments sequentially
    local process_next_arg
    local arg_values = {}
    local arg_index = 1

    process_next_arg = function()
      -- Check if we're done with all arguments
      if arg_index > #args_config then
        -- Build the final command with all collected values
        local final_cmd = cmd_template
        for placeholder, value in pairs(arg_values) do
          final_cmd = final_cmd:gsub("{" .. placeholder .. "}", value)
        end

        -- Run the command
        vim.cmd('RunAsync ' .. final_cmd)

        -- Show notification if provided
        if notify_prefix then
          local args_str = ""
          for _, config in ipairs(args_config) do
            if arg_values[config.placeholder] and arg_values[config.placeholder] ~= "" then
              args_str = args_str .. " " .. config.placeholder .. "=" .. arg_values[config.placeholder]
            end
          end
          vim.notify(notify_prefix .. " " .. filename .. args_str, vim.log.levels.INFO)
        end
        return
      end

      -- Get current argument config
      local arg_config = args_config[arg_index]

      -- Prompt the user for this argument
      vim.ui.input({
        prompt = arg_config.prompt .. ": ",
        default = arg_config.default or "",
      }, function(input)
          if input == nil then -- User cancelled
            return
          end

          -- Store the value
          arg_values[arg_config.placeholder] = input

          -- Move to next argument
          arg_index = arg_index + 1
          process_next_arg()
      	end)
    end

    -- Start processing the first argument
    process_next_arg()
  end
end

return {
  RunInteractive = run_interactive_command_multi,
}
