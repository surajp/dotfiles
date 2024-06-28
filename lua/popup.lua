local function minimize_popup(win)
  vim.api.nvim_win_close(win, true)
end

local function restore_popup(buf, opts)
  return vim.api.nvim_open_win(buf, true, opts)
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
    row = 5,
    col = 10,
    width = 120,
    height = 30,
    style = 'minimal',
    border = 'single',
    title = 'Async Command',
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  return buf, win, opts
end

local function run_async_command(cmd)
  local buf, win, opts = create_popup()
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, {join(cmd)})


  vim.system(cmd, {
    text = true,
    timeout=50000,
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
    vim.schedule(function()
      if data.code == 124 then
        local line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Command timed out"})
        vim.api.nvim_buf_add_highlight(buf, -1, "Error", line_count, 0, -1)
      end
      vim.keymap.set('n', 'qq','<cmd>q<CR>', {buffer = buf})
      restore_popup(buf, opts)  -- Restore the window
    end)
  end
  )

  -- Minimize the popup window after starting the job
  vim.schedule(function()
    sleep(2)
    minimize_popup(win)
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
