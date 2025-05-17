-- Define bookmark sign
vim.fn.sign_define('Bookmark', {
  text = '🔖',
  texthl = 'BookmarkSign',
  linehl = '',
  numhl = ''
})
vim.api.nvim_set_hl(0, 'BookmarkSign', { fg = '#FFD700', bold = true })

local function is_bookmarked(file)
  local bookmarks_file = vim.fn.stdpath('data') .. '/bookmarks.txt'
  local f = io.open(bookmarks_file, 'r')
  if f then
    for line in f:lines() do
      if line == file then
        f:close()
        return true
      end
    end
    f:close()
  end
  return false
end

-- Helper function to update bookmark indicator
local function update_bookmark_indicator()
  local file = vim.fn.expand('%:p')
  local bufnr = vim.api.nvim_get_current_buf()

  -- Remove existing bookmark signs
  vim.fn.sign_unplace('bookmarks', { buffer = bufnr })
  -- Add sign if bookmarked
  if file ~= '' and is_bookmarked(file) then
    vim.fn.sign_place(0, 'bookmarks', 'Bookmark', bufnr, { lnum = 1, priority = 10 })
  end
end

-- Update indicator on buffer enter and when bookmarks change
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  pattern = '*',
  callback = update_bookmark_indicator
})
-- Add current file to bookmarks
vim.keymap.set('n', '<leader>ba', function()
  local file = vim.fn.expand('%:p')
  local bookmarks_file = vim.fn.stdpath('data') .. '/bookmarks.txt'

  -- Check if file is already bookmarked
  local existing = io.open(bookmarks_file, 'r')
  if existing then
    for line in existing:lines() do
      if line == file then
        existing:close()
        vim.notify('Already bookmarked: ' .. file, vim.log.levels.INFO)
        return
      end
    end
    existing:close()
  end

  -- Add bookmark
  local f = io.open(bookmarks_file, 'a')
  if f then
    f:write(file .. '\n')
    f:close()
    vim.notify('Bookmarked: ' .. file, vim.log.levels.INFO)
    update_bookmark_indicator()
  else
    vim.notify('Could not open bookmarks file', vim.log.levels.ERROR)
  end
end, { desc = 'Bookmark add' })

-- Remove bookmark(s)
vim.keymap.set('n', '<leader>br', function()
  local bookmarks_file = vim.fn.stdpath('data') .. '/bookmarks.txt'
  local current_file = vim.fn.expand('%:p')

  -- Read all bookmarks
  local bookmarks = {}
  local f = io.open(bookmarks_file, 'r')
  if f then
    for line in f:lines() do
      if line ~= '' then
        table.insert(bookmarks, line)
      end
    end
    f:close()
  end

  if #bookmarks == 0 then
    vim.notify('No bookmarks to remove', vim.log.levels.WARN)
    return
  end

  -- Check if current file is bookmarked
  local current_is_bookmarked = false
  for _, bookmark in ipairs(bookmarks) do
    if bookmark == current_file then
      current_is_bookmarked = true
      break
    end
  end

  if current_is_bookmarked then
    -- Remove current file directly
    local new_bookmarks = {}
    for _, bookmark in ipairs(bookmarks) do
      if bookmark ~= current_file then
        table.insert(new_bookmarks, bookmark)
      end
    end

    -- Write back
    f = io.open(bookmarks_file, 'w')
    if f then
      for _, bookmark in ipairs(new_bookmarks) do
        f:write(bookmark .. '\n')
      end
      f:close()
      vim.notify('Removed bookmark: ' .. current_file, vim.log.levels.INFO)
      update_bookmark_indicator()
    end
  else
    -- Show FZF to select bookmark to remove
    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
      source = bookmarks,
      sink = function(selected)
        -- Remove selected bookmark
        local new_bookmarks = {}
        for _, bookmark in ipairs(bookmarks) do
          if bookmark ~= selected then
            table.insert(new_bookmarks, bookmark)
          end
        end

        -- Write back
        f = io.open(bookmarks_file, 'w')
        if f then
          for _, bookmark in ipairs(new_bookmarks) do
            f:write(bookmark .. '\n')
          end
          f:close()
          vim.notify('Removed bookmark: ' .. selected, vim.log.levels.INFO)
          -- Update indicator if removed file is current buffer
          if selected == vim.fn.expand('%:p') then
            update_bookmark_indicator()
          end
        end
      end,
      options = '--prompt="Remove bookmark> "'
    }))
  end
end, { desc = 'Bookmark remove' })

-- Open bookmarks with FZF
vim.keymap.set('n', '<leader>bo', function()
  local bookmarks_file = vim.fn.stdpath('data') .. '/bookmarks.txt'
  vim.fn.system('touch ' .. bookmarks_file)
  local preview_cmd = vim.fn.executable('bat') == 1
    and 'bat --style=numbers --color=always --line-range=:500 {}'
    or 'cat {}'
  vim.fn['fzf#run'](vim.fn['fzf#wrap']({
    source = 'cat ' .. vim.fn.shellescape(bookmarks_file),
    ['sink*'] = function(lines)
      local key = lines[1]
      local selected = lines[2]
      if key == 'ctrl-d' then
        -- Delete bookmark
        local bookmarks = {}
        local f = io.open(bookmarks_file, 'r')
        if f then
          for line in f:lines() do
            if line ~= '' and line ~= selected then
              table.insert(bookmarks, line)
            end
          end
          f:close()
        end
        f = io.open(bookmarks_file, 'w')
        if f then
          for _, bookmark in ipairs(bookmarks) do
            f:write(bookmark .. '\n')
          end
          f:close()
          vim.notify('Removed bookmark: ' .. selected, vim.log.levels.INFO)
        end
      elseif key == 'ctrl-x' then
        -- Open in horizontal split
        vim.cmd('split ' .. vim.fn.fnameescape(selected))
      elseif key == 'ctrl-t' then
        -- Open in new tab
        vim.cmd('tabnew ' .. vim.fn.fnameescape(selected))
      elseif key == 'ctrl-v' then
        -- Open in vertical split
        vim.cmd('vsplit ' .. vim.fn.fnameescape(selected))
      else
        -- Default: open in current window (Enter key)
        vim.cmd('edit ' .. vim.fn.fnameescape(selected))
      end
    end,
    options = {
      '--preview', preview_cmd,
      '--prompt', 'Bookmarks> ',
      '--expect', 'ctrl-d,ctrl-x,ctrl-t,ctrl-v',
      '--header', 'Enter=open | Ctrl-d=delete | Ctrl-x=split | Ctrl-v=vsplit | Ctrl-t=tab'
    }
  }))
end, { desc = 'Bookmark open' })
