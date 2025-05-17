local M = {}

-- Configuration
local config = {
  output_format = 'csv', -- csv, json, table, markdown
  max_rows = 1000,
  temp_db = vim.fn.tempname() .. '.duckdb',
  show_timing = true,
}

local function get_file_type(filepath)
  local ext = vim.fn.fnamemodify(filepath, ':e'):lower()
  if ext == 'csv' then return 'csv'
  elseif ext == 'json' or ext == 'jsonl' then return 'json'
  else return 'csv' end
end

local function build_query_with_files(query, current_file)
  -- Auto-detect and substitute file references
  if current_file and vim.fn.filereadable(current_file) == 1 then
    local file_type = get_file_type(current_file)
    local table_name = vim.fn.fnamemodify(current_file, ':t')
    local table_name_no_ext = vim.fn.fnamemodify(current_file, ':t:r')

    -- If query doesn't contain FROM, assume they want to query current file
    if not query:match('FROM%s+') and not query:match('from%s+') then
      if query:match('^%s*SELECT') or query:match('^%s*select') then
        query = query .. ' FROM ' .. table_name_no_ext
      end
    end

    if query:find(vim.pesc(table_name)) then
      query = query:gsub(vim.pesc(table_name), string.format("read_%s_auto('%s',sample_size=5000,ignore_errors=true)", file_type, current_file))

    else
      query = query:gsub(vim.pesc(table_name_no_ext), string.format("read_%s_auto('%s',sample_size=5000,ignore_errors=true)", file_type, current_file))
    end
  end

  return query
end

local function results_pane(output, query, start_time)
  vim.opt_local.winbar = nil

  if output.code == 0 then
    local duration = start_time and (vim.loop.hrtime() - start_time) / 1e6 or 0
    local temp_file = vim.fn.tempname() .. '.' .. config.output_format

    local lines = vim.fn.split(output.stdout, "\n")

    vim.fn.writefile(lines, temp_file)

    -- Choose viewer based on format
    local viewer_cmd
    if config.output_format == 'csv' or config.output_format == 'json' then
      viewer_cmd = 'visidata ' .. vim.fn.shellescape(temp_file)
    else
      viewer_cmd = 'less ' .. vim.fn.shellescape(temp_file)
    end

    vim.cmd('split')
    vim.cmd('resize 20')
    vim.cmd('terminal ' .. viewer_cmd)
    vim.cmd('wincmd _')
    vim.cmd('startinsert')

    -- Store query in history
    M.add_to_history(query)

    vim.api.nvim_create_autocmd("TermClose", {
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        vim.fn.delete(temp_file)
      end,
      once = true
    })
  else
    local error_lines = vim.fn.split(output.stderr, "\n")
    table.insert(error_lines, 1, "DuckDB Error (Code: " .. output.code .. ")")

    local new_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, error_lines)
    vim.api.nvim_buf_set_option(new_buf, 'filetype', 'text')

    vim.api.nvim_open_win(new_buf, true, {
      split = 'above',
      height = math.min(#error_lines + 2, 15),
    })
  end
end

local function duckdb(args)
  local range = args.range
  local line1 = args.line1 - 1
  local line2 = args.line2
  line2 = line1 == line2 and line1 + 1 or line2
  local stdin = vim.api.nvim_buf_get_lines(0, line1, line2, false)

  if range == 0 then
    print('No query selected. Use visual mode to select SQL query.')
    return
  end

  local query = table.concat(stdin, "\n")
  local current_file = vim.fn.expand('%:p')

  -- Enhance query with file context
  query = build_query_with_files(query, current_file)

  -- Build DuckDB command
  local format_flag = config.output_format == 'csv' and '-csv' 
  or config.output_format == 'json' and '-json'
  or config.output_format == 'markdown' and '-markdown'
  or '-table'

  local cmd = string.format('duckdb %s %s', format_flag, config.temp_db)

  vim.opt_local.winbar = "DuckDB: " .. query:gsub("\n", " ") .. "%="

  local start_time = vim.loop.hrtime()
  vim.system({'bash', '-c', cmd}, {
    text = true, 
    stdin = {query}
  }, vim.schedule_wrap(function(output)
      results_pane(output, query, start_time)
    end))
end

-- Query history management
M.history = {}

function M.add_to_history(query)
  table.insert(M.history, 1, {
    query = query,
    timestamp = os.date('%Y-%m-%d %H:%M:%S')
  })
  -- Keep only last 50 queries
  if #M.history > 50 then
    table.remove(M.history)
  end
end

function M.show_history()
  if #M.history == 0 then
    print("No query history")
    return
  end

  local items = {}
  for i, entry in ipairs(M.history) do
    table.insert(items, string.format("%d: %s (%s)", i, entry.query:gsub("\n", " "), entry.timestamp))
  end

  vim.ui.select(items, {
    prompt = "Select query from history:",
  }, function(choice, idx)
      if choice and idx then
        -- Insert selected query at cursor
        local query_lines = vim.fn.split(M.history[idx].query, "\n")
        vim.api.nvim_put(query_lines, 'l', true, true)
      end
    end)
end

-- Quick commands for common operations
function M.describe_table()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.filereadable(current_file) == 1 then
    local table_name = vim.fn.fnamemodify(current_file, ':t')
    local file_type = get_file_type(current_file)
    local query = string.format("DESCRIBE read_%s_auto('%s')", file_type, current_file)

    vim.api.nvim_put({query}, 'l', true, true)
  else
    print("Current buffer is not a readable file")
  end
end

function M.show_summary()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.filereadable(current_file) == 1 then
    local file_type = get_file_type(current_file)
    local query = string.format("SUMMARIZE SELECT * FROM read_%s_auto('%s')", file_type, current_file)

    vim.api.nvim_put({query}, 'l', true, true)
  else
    print("Current buffer is not a readable file")
  end
end

function M.show_schema()
  local query = "SHOW TABLES"
  vim.api.nvim_put({query}, 'l', true, true)
end

-- Configuration commands
function M.set_format(format)
  if vim.tbl_contains({'csv', 'json', 'table', 'markdown'}, format) then
    config.output_format = format
    print("Output format set to: " .. format)
  else
    print("Invalid format. Use: csv, json, table, or markdown")
  end
end

-- Main command
vim.api.nvim_create_user_command("Duckdb", duckdb, {
  range = true,
  bang = true,
})

-- Additional commands
vim.api.nvim_create_user_command("DuckdbHistory", M.show_history, {})
vim.api.nvim_create_user_command("DuckdbDescribe", M.describe_table, {})
vim.api.nvim_create_user_command("DuckdbSummarize", M.show_summary, {})
vim.api.nvim_create_user_command("DuckdbSchema", M.show_schema, {})
vim.api.nvim_create_user_command("DuckdbFormat", function(args)
  M.set_format(args.args)
end, {
    nargs = 1,
    complete = function() return {'csv', 'json', 'table', 'markdown'} end
  })

return M
