-- Run an asynchronous command in a popup that minimizes and is automatically restored when the command finishes execution
local M = {}

M.config = {
  timeout = 180000,
  sleep = 2,
  height = 30,
  width = 120,
  left = 10,
  top = 5
}

M.setup= function(userconfig)
  M.config = vim.tbl_deep_extend('force',M.config,userconfig)
end

local function minimize_popup(win)
  vim.api.nvim_win_close(win, true)
end

local function restore_popup(buf, opts)
  -- Check if the buffer is already visible in any window
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_buf(win) == buf then
      -- Buffer is already visible, focus on the window
      vim.api.nvim_set_current_win(win)
      return win
    end
  end

  -- Buffer is not visible, open a new window
  local win =  vim.api.nvim_open_win(buf, true, opts)
  vim.keymap.set('n','<leader>pq',function() minimize_popup(win) end,{})
  return win
end

local function sleep(n)
  vim.cmd(tonumber(n).."sleep")
end

local function join(arr,separator)
  if not separator then
    separator=" "
  end
  local val = vim.iter(arr):fold("",function(acc,k)
    acc=acc..separator..k
    return acc
  end)
  return val
end

local function create_popup()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Running command..."})
  local opts = {
    relative = 'editor',
    row = M.config.top,
    col = M.config.left,
    width = M.config.width,
    height = M.config.height,
    style = 'minimal',
    border = 'single',
    title = 'Async Command',
  }

  local win = restore_popup(buf,opts)
  return buf, win, opts
end

local function run_async_command(cmd)
  local buf, win, opts = create_popup()
  local complete = false
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, {join(cmd)})
  vim.keymap.set('n','<leader>pm',function() restore_popup(buf,opts) end,{})

  vim.system(cmd, {
    text = true,
    timeout= M.config.timeout,
    stdout = function(_, data)
      vim.schedule(function()
        if data then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(data,"\n"))
        end
      end)
    end,
    stderr = function(_, data)
      vim.schedule(function()
        if data then
          local line_count_start = vim.api.nvim_buf_line_count(buf)
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(data,"\n"))
          local line_count_end = vim.api.nvim_buf_line_count(buf)
          for i = line_count_start, line_count_end - 1 do
            -- Use a built-in highlight group, e.g., 'Error' for red text
            vim.api.nvim_buf_add_highlight(buf, -1, "Error", i, 0, -1)
          end
        end
      end)
    end
  },
  function(data)
    complete = true
    vim.schedule(function()
      if data.code == 124 then
        local line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Command timed out"})
        vim.api.nvim_buf_add_highlight(buf, -1, "Error", line_count, 0, -1)
      end
      vim.keymap.set('n', 'qq',function() vim.api.nvim_buf_delete(buf,{force=true}) end,{buffer=buf})
      restore_popup(buf, opts)  -- Restore the window
      vim.keymap.del('n', '<leader>pq')
      vim.keymap.del('n', '<leader>pm')
    end)
  end
  )

  -- Minimize the popup window after starting the job
  vim.schedule(function()
    sleep(M.config.sleep)
    if complete == false then
      minimize_popup(win)
    end
  end)

end


vim.api.nvim_create_user_command('RunAsync', function(opts)
  local cmd = opts.fargs
  cmd = vim.iter(cmd):map(function(val)
    return vim.fn.expand(val)
  end):totable()
  -- local cmd = opts.args
  run_async_command(cmd)
end, { nargs = "*" })

return M
