-- Replace the `<Cmd>Snippets<CR>` mapping with this helper so FZF lists LuaSnip snippets.
local function fzf_luasnip_snippets()
  local luasnip = require('luasnip')
  local ft = vim.bo.filetype
  local snippets = luasnip.get_snippets(ft) or {}
  if vim.tbl_isempty(snippets) then
    vim.notify('No LuaSnip snippets for ' .. ft, vim.log.levels.INFO)
    return
  end

  local candidates = {}
  local lookup = {}
  for _, snippet in ipairs(snippets) do
    local label = snippet.name or ('snippet_' .. tostring(#candidates + 1))
    if snippet.description then
      label = label .. ' | ' .. table.concat(snippet.description, ' ')
    end
    candidates[#candidates + 1] = label
    lookup[label] = snippet
  end

  vim.fn['fzf#run']({
    source = candidates,
    sink = function(choice)
      local snippet = lookup[choice]
      if snippet then
        luasnip.snip_expand(snippet)
      end
    end,
    options = '--prompt="LuaSnip Snippets> " --border=rounded --height=40%',
  })
end

vim.keymap.set({'n','i'}, '<C-f>s', fzf_luasnip_snippets, { noremap = true, silent = true, desc = 'FZF LuaSnip Snippets' })
