-- Subtle background tint when current file is not git-tracked

-- highlight group for window background
local HL_GROUP = "GitUntrackedWindowBG"
local normalbg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg

local function compute_untracked_bg()
  local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
  if not ok or not normal or not normal.bg then
    return
  end
  local r = math.floor(normalbg / 0x10000)
  local g = math.floor((normalbg % 0x10000) / 0x100)
  local b = normalbg % 0x100

  -- subtle shift depending on background
  local delta = (vim.o.background == "dark") and 20 or -20
  local function clamp(x) return math.max(0, math.min(255, x + delta)) end

  r, g, b = clamp(r), clamp(g), clamp(b)
  local newbg = r * 0x10000 + g * 0x100 + b

  pcall(vim.api.nvim_set_hl, 0, HL_GROUP, { bg = newbg })
end

compute_untracked_bg()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("GitUntrackedIndicatorColor", { clear = true }),
  callback = compute_untracked_bg,
})

local function is_git_tracked(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" or vim.bo[bufnr].buftype ~= "" then
    return false, false
  end
  if vim.fn.filereadable(fname) == 0 then
    return false, false
  end

  local abs = vim.fn.fnamemodify(fname, ":p")
  local dir = vim.fn.fnamemodify(abs, ":h")

  vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" })
  if vim.v.shell_error ~= 0 then
    return false, false
  end

  local root = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    return false, false
  end

  root = vim.fn.fnamemodify(root, ":p")
  local rel
  if string.sub(abs, 1, #root) == root then
    if string.sub(abs, #root + 1, #root + 1) == "/" then
      rel = string.sub(abs, #root + 2)
    else
      rel = string.sub(abs, #root + 1)
    end
  else
    rel = abs
  end

  vim.fn.systemlist({ "git", "-C", root, "ls-files", "--error-unmatch", "--", rel })
  local tracked = (vim.v.shell_error == 0)
  return tracked, true
end

local function apply_untracked_bg(bufnr)
  compute_untracked_bg()
  local normal_map = "Normal:" .. HL_GROUP
  local eob_map = "EndOfBuffer:" .. HL_GROUP

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      local cur = vim.wo[win].winhighlight or ""

      -- strip existing duplicates of our entries, track presence
      local parts = {}
      local has_normal, has_eob = false, false
      for entry in string.gmatch(cur, "([^,]+)") do
        entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
        if entry == normal_map then
          has_normal = true
        elseif entry == eob_map then
          has_eob = true
        else
          table.insert(parts, entry)
        end
      end

      -- capture previous only once, and only if we haven't applied yet
      if vim.w[win].__git_untracked_prev_winhl == nil and not (has_normal or has_eob) then
        vim.w[win].__git_untracked_prev_winhl = cur
      end

      -- ensure our mappings are present exactly once and at the front
      table.insert(parts, 1, eob_map)
      table.insert(parts, 1, normal_map)

      local newhl = table.concat(parts, ",")
      if newhl ~= cur then
        vim.wo[win].winhighlight = newhl
      end
    end
  end
end

local function remove_untracked_bg(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      local prev = vim.w[win].__git_untracked_prev_winhl
      if prev ~= nil then
        vim.wo[win].winhighlight = prev
        vim.w[win].__git_untracked_prev_winhl = nil
      else
        -- best-effort cleanup if prev wasn't captured
        local curr = vim.wo[win].winhighlight or ""
        local cleaned_parts = {}
        for entry in string.gmatch(curr, "([^,]+)") do
          if entry ~= ("Normal:" .. HL_GROUP) and entry ~= ("EndOfBuffer:" .. HL_GROUP) then
            table.insert(cleaned_parts, entry)
          end
        end
        vim.wo[win].winhighlight = table.concat(cleaned_parts, ",")
      end
    end
  end
end

local git_untracked_grp = vim.api.nvim_create_augroup("GitUntrackedIndicator", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter"}, {
  group = git_untracked_grp,
  callback = function(args)
    local tracked, in_repo = is_git_tracked(args.buf)
    if in_repo and not tracked then
      apply_untracked_bg(args.buf)
    else
      remove_untracked_bg(args.buf)
    end
  end,
})
