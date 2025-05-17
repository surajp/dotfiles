-- ~/.config/nvim/init.lua

-- =============================================================================
-- Bootstrap lazy.nvim
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Set leader key

require('lazy').setup({
  spec = {
    { import = 'plugins' }, -- Load all plugins from plugins folder
  },
  defaults = {
    lazy = false, 
  },
})

-- =============================================================================
-- Global Settings
-- =============================================================================

vim.g.loaded_perl_provider = 0 -- Disable perl provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider

-- Options (set)
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.cmd('syntax on')              -- Enable syntax highlighting (TreeSitter often overrides this)
vim.opt.expandtab = false         -- Use real tabs, not spaces
vim.opt.copyindent = true         -- Copy indentation from previous line
vim.opt.preserveindent = true     -- Preserve indentation structure
vim.opt.lazyredraw = true         -- Don't redraw while executing macros (performance)
vim.opt.ignorecase = true         -- Ignore case in searches
vim.opt.smartcase = true          -- Override ignorecase if search pattern has uppercase
vim.opt.tabstop = 8               -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 2            -- Number of spaces to use for autoindent
vim.opt.softtabstop = 2           -- Number of spaces <Tab> inserts in insert mode
vim.opt.colorcolumn = "120"       -- Highlight column 120
vim.opt.hidden = true             -- Allow buffer switching without saving
vim.opt.scrolloff = 8             -- Keep 8 lines visible above/below cursor
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.mouse = ""                -- Disable mouse support
vim.opt.spell = true              -- Enable spell checking
vim.opt.spelllang = "en_us"       -- Set spell check language
vim.opt.background = "dark"       -- Assume dark background
vim.opt.foldmethod = "expr"       -- Use expression for folding (TreeSitter)
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- TreeSitter fold expression
vim.opt.foldlevel = 1             -- Start with folds closed (level 1)
vim.opt.foldnestmax = 30          -- Max fold nesting
vim.opt.complete:append("k")      -- Add dictionary completion source
vim.opt.dictionary:append("/usr/share/dict/words") -- Add system dictionary
vim.opt.laststatus = 2            -- Always show status line
vim.opt.path:append("**")         -- Search recursively in subfolders using 'find'
vim.opt.wildignore:append("**/node_modules/**") -- Ignore node_modules for wildmenu/find
vim.opt.omnifunc = "ale#completion#OmniFunc" -- Set omnifunc for ALE

if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true      -- Enable true color support if available
end

-- Cursor style (keep the Vimscript string format)
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Environment variables
vim.fn.setenv('FZF_DEFAULT_OPTS', "--preview-window 'right:50%' --margin=1,4 --bind=alt-k:preview-page-up,alt-j:preview-page-down,ctrl-a:select-all")

-- Add ~/.scripts to PATH if not already present
local path = vim.fn.getenv('PATH') or ''
local scripts_path = vim.fn.expand('~/.scripts')
if not path:find(scripts_path, 1, true) then
  vim.fn.setenv('PATH', scripts_path .. ':' .. path)
end

-- Persistent Undo
if vim.fn.has("persistent_undo") == 1 then
  local target_path = vim.fn.expand('~/.undodir')
  -- Create the directory and any parent directories if it doesn't exist.
  if vim.fn.isdirectory(target_path) == 0 then
    vim.fn.mkdir(target_path, "p", 0700)
  end
  vim.opt.undodir = target_path
  vim.opt.undofile = true
end

-- Enable filetype detection, plugins, and indenting
vim.cmd('filetype plugin indent on')

-- Syntax sync (for performance on large files)
vim.cmd('syntax sync minlines=10000')

-- =============================================================================
-- Helper Functions
-- =============================================================================

-- Function to find sfdx-project.json workspace folder (Lua translation)
local function find_workspace_folder(start_path)
  local marker = 'sfdx-project.json'
  -- Limit search upwards to avoid scanning the entire filesystem unnecessarily
  -- Adjust '/Users/surajpillai/projects' or use vim.fn.expand('~') or '/' as needed
  local root_limit = '/Users/surajpillai/projects'
  local start_dir = vim.fn.fnamemodify(start_path, ':h')
  local found_path = vim.fn.findfile(marker, start_dir .. ';/', root_limit)
  if found_path ~= '' then
    return vim.fn.fnamemodify(found_path, ':h')
  else
    -- Optionally return a default or nil if not found
    return nil
  end
end

-- Transparency Toggle Function
local is_transparent = false
local original_colorscheme = "iceberg" -- Store your default colorscheme

local function make_transparent()
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" }) -- For inactive splits
  vim.api.nvim_set_hl(0, "NonText", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
  -- Add other highlight groups if needed
  is_transparent = true
end

local function remove_transparent()
  -- Ensure the colorscheme name is stored correctly
  if vim.g.colors_name and vim.g.colors_name ~= "" then
    vim.cmd("colorscheme " .. vim.g.colors_name)
  else
    vim.cmd("colorscheme " .. original_colorscheme) -- Fallback
  end
  is_transparent = false
end

local function toggle_transparent()
  if not vim.g.colors_name or vim.g.colors_name == "" then
    vim.g.colors_name = original_colorscheme -- Ensure it's set before first toggle
  end
  if is_transparent then
    remove_transparent()
  else
    make_transparent()
  end
end

-- =============================================================================
-- Autocommands
-- =============================================================================
vim.api.nvim_create_augroup("FileTypeGroupLua", { clear = true })
local ft_group = "FileTypeGroupLua"

-- General Filetype Settings
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = {"*.cls", "*.trigger", "*.apex"}, group = ft_group, command = "set filetype=apex syntax=apex" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "*.soql", group = ft_group, command = "set filetype=apex syntax=sql | UltiSnipsAddFiletypes sql" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "project-scratch-def.json", group = ft_group, command = "set filetype=scratch syntax=json" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = {"*.vue", "*.svelte", "*.jsw", "*.cmp", "*.page", "*.component"}, group = ft_group, command = "set filetype=html" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = {"*.jsw"}, group = ft_group, command = "set filetype=javascript" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "*.jsx", group = ft_group, command = "set filetype=javascript.jsx" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "*-meta.xml", group = ft_group, command = "UltiSnipsAddFiletypes meta.xml" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "**/lwc/*.js", group = ft_group, command = "set filetype=lwc syntax=javascript | UltiSnipsAddFiletypes lwc.js" })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = "*.rc", group = ft_group, command = "set filetype=sh" })

-- Quickfix window settings
vim.api.nvim_create_autocmd("FileType", { pattern = "qf", group = ft_group, callback = function()
  vim.keymap.set("n", "<CR>", "<CR>", { buffer = true, noremap = true })
  vim.opt_local.wrap = false
  vim.opt_local.winheight = 15 -- Equivalent to set wh=15
end})

-- XML/JSON specific mappings
vim.api.nvim_create_autocmd("FileType", { pattern = "xml", group = ft_group, callback = function()
  vim.keymap.set("n", "<Leader>$", "<Cmd>%!fxparser | jq<CR><Cmd>set ft=json<CR>ggj4dd<CR>", { buffer = true, noremap = true, silent = true })
end})
vim.api.nvim_create_autocmd("FileType", { pattern = "json", group = ft_group, callback = function()
  vim.keymap.set("n", "<Leader>#", "<Cmd>ea 1f<CR><Cmd>set ft=xml<CR>", { buffer = true, noremap = true, silent = true })
end})


-- Set b:workspace_folder for Salesforce files
vim.api.nvim_create_augroup("ApexSpecificLua", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "apex",
  group = "ApexSpecificLua",
  callback = function()
    local ws = find_workspace_folder(vim.fn.expand('%:p'))
    if ws then
      vim.b.workspace_folder = ws
      -- Optional: print("Set workspace folder for Apex: " .. vim.b.workspace_folder)
    end
  end,
})

vim.api.nvim_create_augroup("LwcSpecificLua", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lwc",
  group = "LwcSpecificLua",
  callback = function()
    local ws = find_workspace_folder(vim.fn.expand('%:p'))
    if ws then
      vim.b.workspace_folder = ws
      -- Optional: print("Set workspace folder for LWC: " .. vim.b.workspace_folder)
    end
  end,
})

-- Function to potentially disable ALE/Syntax for large files
local function check_disable_ale()
  if vim.fn.line("$") > 500 then
    vim.cmd("ALEDisableBuffer")
    vim.cmd("ALEDisableFixersBuffer") -- Use the command defined later
    print("ALE and Fixers disabled for large file.")
  end
end

local function check_disable_all()
  -- Check total byte size of first ~10k lines for performance
  local total_len = 0
  local max_lines_to_check = 10002
  local buf_lines = vim.fn.line("$")
  for i = 1, math.min(buf_lines, max_lines_to_check) do
    -- Get line content without allocation if possible, # gets byte length
    local line_content = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line_content then
      total_len = total_len + #line_content
    end
    if total_len > 100000 then break end
  end

  if total_len > 100000 or vim.fn.line("$") > 10000 then
     -- Disable heavy plugins
     vim.cmd("ALEDisableBuffer")
     vim.cmd("ALEDisableFixersBuffer")
     vim.cmd("TSBufDisable highlight") -- Disable TreeSitter highlighting
     vim.cmd("TSBufDisable indent") -- Disable TreeSitter indentation
     vim.cmd("TSBufDisable incremental_selection")
     vim.cmd("TSBufDisable textobjects")
     
     -- Keep basic syntax highlighting but disable heavy features
     vim.wo.foldmethod = 'manual' -- Disable syntax-based folding
     vim.wo.cursorline = false -- Disable cursor line highlighting
     vim.wo.cursorcolumn = false -- Disable cursor column highlighting
     
     -- Disable LSP for this buffer only
     local clients = vim.lsp.get_clients({bufnr = 0})
     for _, client in pairs(clients) do
       vim.lsp.buf_detach_client(0, client.id)
     end
  end
end

vim.api.nvim_create_augroup("ALEGroupLua", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", { pattern = "*", callback = check_disable_ale, group = "ALEGroupLua" }) -- Use BufReadPost
vim.api.nvim_create_autocmd("BufReadPost", { pattern = "*", callback = check_disable_all, group = "ALEGroupLua" })

-- =============================================================================
-- User Commands
-- =============================================================================

-- Wipe Registers
vim.api.nvim_create_user_command("WipeReg", function()
  print("Wiping registers...")
  for i = 34, 122 do
    -- Exclude special registers like ", *, +, ., %, #, :, /
    local char = string.char(i)
    if not char:match('[/%"%*%+%.:#]') then
      pcall(vim.fn.setreg, char, {})
    end
  end
  print("Registers wiped.")
end, {})

-- FZF Grep Commands (using vim.cmd for simplicity with fzf# functions)
vim.cmd([[
  command! -bang -nargs=* GGrepI
  \ call fzf#vim#grep(
  \   'git grep -i --line-number -- '.fzf#shellescape(<q-args>).' || echo ""',
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

  command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(
  \   <q-args>,
  \   {'options':['--preview','bat {} --color always']},<bang>0)

  command! -bang -nargs=? -complete=file Commits
  \ call fzf#vim#commits(
  \   <q-args>,
  \   {'options':['--preview','git show --color=always $(cut -d " " -f1 {})']},<bang>0)
]])

-- Prevent common typos for save/quit
vim.api.nvim_create_user_command("W", "w", { bang = true })
vim.api.nvim_create_user_command("Wq", "wq", { bang = true })
vim.api.nvim_create_user_command("Wqa", "wqa", { bang = true })
vim.api.nvim_create_user_command("Q", "q", { bang = true })
vim.api.nvim_create_user_command("Qa", "qa", { bang = true })

-- Make blank lines truly blank
vim.api.nvim_create_user_command("BL", "%s/^\\(\\s\\|\\t\\)*$//g", {})

-- ALE Fixer Toggle Commands
vim.api.nvim_create_user_command("ALEDisableFixersBuffer", "let b:ale_fix_on_save = 0", {})
vim.api.nvim_create_user_command("ALEToggleFixers", "let b:ale_fix_on_save = get(b:, 'ale_fix_on_save', 0) ? 0 : 1", {})


local interactive = require('interactive')

-- =============================================================================
-- Key Mappings
-- =============================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General Mappings
map("n", "<leader>H", "<Cmd>lcd %:p:h<CR>", opts) -- Change directory to current file's dir
map("n", "<A-a>", "<C-a>", opts) -- Remap Alt-a to Ctrl-a (increment)
map("i", "jk", "<Esc>", { noremap = true }) -- Escape in insert mode
map("i", "kj", "<Esc>", { noremap = true })
map("n", "j", "gj", { noremap = true }) -- Navigate visual lines
map("n", "k", "gk", { noremap = true })
map("n", "<CR>", ":", { noremap = true }) -- Enter to command mode
map("t", "kkk", "<C-\\><C-n>", opts) -- Escape from terminal mode (like Ctrl-\ Ctrl-n)
map("n", "<C-j>", "<Cmd>cnext<CR>", opts) -- Navigate quickfix list
map("n", "<C-k>", "<Cmd>cprev<CR>", opts)
map("n", "<Leader>m", "<Cmd>G<CR>", opts) -- Fugitive Git status
map("n", "<Leader>r", "<Cmd>e<CR>", opts) -- Reload file

-- Toggle Highlight Search
local hlstate = 0
map("n", "<leader>;", function()
  hlstate = hlstate + 1
  if hlstate % 2 == 1 then
    vim.cmd('nohlsearch')
  else
    vim.opt.hlsearch = true
  end
  vim.cmd('redraw') -- Redraw needed after echo usually
  vim.cmd('echo')   -- Clear message area
end, opts)

map("n", "<leader>tm", "<Cmd>bo 15sp +te<CR>A", opts) -- Open terminal below
map("n", "<C-w>m", "<C-w>_<C-w>|", opts) -- Maximize window
map("n", "<C-w><Left>", "<Cmd>vertical resize -5<CR>", opts) -- Resize window
map("n", "<C-w><Right>", "<Cmd>vertical resize +5<CR>", opts)
map("n", "<C-w><Down>", "<Cmd>resize +5<CR>", opts)
map("n", "<C-w><Up>", "<Cmd>resize -5<CR>", opts) -- Note: Original had +5, assuming -5 was intended for Up
map("n", "<C-s>", "<Cmd>ls<CR>:b<Space>", opts) -- List buffers and switch

map("n", "zm", "zMza", { noremap = true }) -- Close folds more aggressively
map("n", "zr", "zR", { noremap = true }) -- Open all folds

map("n", "<C-e>", "<Cmd>tabnew ~/.config/nvim/init.lua<CR>", opts) -- Edit init.lua
map("n", "<Leader>l", "<Cmd>tabnew ~/.config/nvim/lua<CR>", opts)  -- Open lua config dir
map("n", "<leader>ow", "<Cmd>tabnew ~/.local/share/nvim/swap/<CR>", opts) -- Open swap dir
map("n", "++", "<Cmd>!git add %<CR>", opts) -- Git add current file

-- Apex Test & Deploy Mappings (Using RunAsync - ensure this command is available)
-- Assumes RunAsync is defined elsewhere (e.g., by parallelpopup.nvim or custom)
map("n", "]t", "<Cmd>RunAsync sfdx apex:run:test -r human -w 5 -n %:t:r<CR>", opts)
map("n", "]T", "<Cmd>RunAsync sfdx apex:run:test -c -r human -w 5 -n %:t:r<CR>", opts)
-- map("n", "]to", ":RunAsync sfdx apex:run:test -r human -w 5 -n %:t:r -o ", opts)

map("n", "]to", function()
  local filename = vim.fn.expand("%:t:r")
  interactive.RunInteractive(
    "sfdx apex:run:test -r human -w 5 -n " .. filename .. " -o {org}",
    {
      { placeholder = "org", prompt = "Org name", default = "" },
    },
    "Running test with output"
  )()
end, opts)

-- map("n", "]To", ":RunAsync sfdx apex:run:test -c -r human -w 5 -n %:t:r -o ", opts)
map("n", "]To", function()
  local filename = vim.fn.expand("%:t:r")
  interactive.RunInteractive(
    "sfdx apex:run:test -c -r human -w 5 -n " .. filename .. " -o {org}",
    {
      { placeholder = "org", prompt = "Org name", default = "" },
    },
    "Running test with output"
  )()
end, opts)

map("n", "]td", "<Cmd>RunAsync sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n %:t:r<CR>", opts)
map("n", "<leader>cc", "<Cmd>tabnew /tmp/coverage<CR>", opts)

-- Run test method under cursor
map("n", "]tt", function()
  if vim.fn.search("@IsTest", "b") == 0 then
    print("No test method found.")
    return
  end
  vim.cmd([[ normal! j0f(h"tyiw<C-o> ]]) -- Move to the next line, find '(', and yank the word
  print("Test method name: " .. vim.fn.getreg('t'))
  local test_name = vim.fn.getreg('t')
  local file_name = vim.fn.expand('%:t:r')
  if test_name ~= '' and file_name ~= '' then
    vim.cmd("RunAsync sfdx apex:run:test -r human -w 6 -t " .. file_name .. "." .. test_name)
  else
    print("Could not determine test method name.")
  end
  vim.cmd('nohlsearch')
end, opts)

map("n", "]tT", function()
  if vim.fn.search("@IsTest", "b") == 0 then
    print("No test method found.")
    return
  end
  vim.cmd([[ normal! j0f(h"tyiw<C-o> ]]) -- Move to the next line, find '(', and yank the word
  print("Test method name: " .. vim.fn.getreg('t'))
  local test_name = vim.fn.getreg('t')
  local file_name = vim.fn.expand('%:t:r')
  if test_name ~= '' and file_name ~= '' then
    vim.cmd("RunAsync sfdx apex:run:test -r human -c -w 6 -t " .. file_name .. "." .. test_name)
  else
    print("Could not determine test method name.")
  end
  vim.cmd('nohlsearch')
end, opts)

map("n", "]TT", function()
  if vim.fn.search("@IsTest", "b") == 0 then
    print("No test method found.")
    return
  end
  vim.cmd([[ normal! j0f(h"tyiw<C-o> ]]) -- Move to the next line, find '(', and yank the word
  print("Test method name: " .. vim.fn.getreg('t'))
  local test_name = vim.fn.getreg('t')
  local file_name = vim.fn.expand('%:t:r')
  if test_name ~= '' and file_name ~= '' then
    vim.cmd("RunAsync sfdx apex:run:test -y -c -r human -w 5 -t " .. file_name .. "." .. test_name .. " -o")
  else
    print("Could not determine test method name.")
  end
  vim.cmd('nohlsearch')
end, opts)

-- AI/Fabric Mappings (Keep using :term via vim.cmd)
map("n", "<leader>ai", [[<Cmd>tabnew | term cat # > /tmp/analyze.txt && echo "//Explain this code and suggest improvements" >> /tmp/analyze.txt && cat /tmp/analyze.txt | fabric -sp sf_dev --model llama3.2:latest<CR><CR>]], opts)
map("n", "<leader>af", [[<Cmd>tabnew | term cat # > /tmp/analyze.txt && echo "\n//Explain this salesforce flow. Be precise and concise. Use bullet points to illustrate the process clearly. Call out the type of flow and how the flow is triggered as well. In the end give a 2-3 sentence summary of the flow and the business use case it is potentially solving for" >> /tmp/analyze.txt && cat /tmp/analyze.txt | fabric -sp sf_dev --model gpt-4o-mini<CR><CR>]], opts)

-- SFDX Deploy/Retrieve
map("n", "]a", "<Cmd>RunAsync sfdx project:deploy:start<CR>", opts)
map("n", "]af", "<Cmd>RunAsync sfdx project:deploy:start -c<CR>", opts)
map("n", "]u", "<Cmd>RunAsync sfdx project:retrieve:start<CR>", opts)
map("n", "]uf", "<Cmd>RunAsync sfdx project:retrieve:start -c<CR>", opts)
-- map("n", "<leader>[", ":<C-u>RunAsync sfdx project:retrieve:start -d % -o ", opts)

map("n", "<leader>[", function()
  interactive.RunInteractive(
    "sfdx project:retrieve:start -d % -o {org}",
    {
      { placeholder = "org", prompt = "Org name", default = "" },
    },
    "Retrieving source"
  )()
end, opts)

map("n", "<leader>[[", "<Cmd>RunAsync sfdx project:retrieve:start -d %<CR>", opts)
-- map("n", "]d", ":<C-u>RunAsync sfdx project:deploy:start -d % -l NoTestRun -w 5 -o ", opts)

map("n", "]d", function()
  interactive.RunInteractive(
    "sfdx project:deploy:start -d % -l NoTestRun -w 5 -o {org}",
    {
      { placeholder = "org", prompt = "Org name", default = "" },
    },
    "Deploying source"
  )()
end, opts)

map("n", "]dd", "<Cmd>RunAsync sfdx project:deploy:start -d % -l NoTestRun -w 5<CR>", opts)

-- Execute Anonymous Apex
-- map("n", "]e", ":<C-u>RunAsync sfdx apex:run -f % -o ", opts)

map("n", "]e", function()
  interactive.RunInteractive(
    "sfdx apex:run -f % -o {org}",
    {
      { placeholder = "org", prompt = "Org name", default = "" },
    },
    "Running anonymous apex"
  )()
end, opts)

map("n", "]ee", "<Cmd>RunAsync sfdx apex:run -f %<CR>", opts)
map("n", "]ej", "<Cmd>RunAsync sfdx apex:run -f % --json<CR>", opts)

-- Vim Grep Current Word
map("n", "]ss", 'yiw:Rg! <C-r>=tolower(@")<CR><CR>', { noremap = true, silent = false }) -- Needs interactive input

-- Buffer Navigation
map("n", "gn", "<Cmd>bnext<CR>", opts)
map("n", "gp", "<Cmd>bprevious<CR>", opts)
map("n", "<leader>-", "<Cmd>bdelete!<CR>", opts)

-- Apex Logs (Keep using :term via vim.cmd)
map("n", "]l", ":<C-u>tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color -o | tee /tmp/apexlogs.log<C-left><C-left><C-left>", opts)
map("n", "]ll", "<Cmd>tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color | tee /tmp/apexlogs.log<CR>", opts)
  map("n", "]li", "<Cmd>tabnew | read !sfdx apex:log:list<CR>", opts)
  map("n", "]gl", function() -- Get log by ID under cursor
    -- Move to the beginning of the line and search for "07L" on the current line
    local current_line = vim.fn.line('.')
    vim.cmd("normal! 0")
    vim.cmd("normal! /\\%" .. current_line .. "l07L<CR>")
    vim.cmd("nohlsearch")

    -- Yank the word under the cursor into register 'a'
    vim.cmd([[ normal! "ayiw ]])
    local log_id = vim.fn.getreg('a')

    -- Validate the log ID and open a new tab with the log
    if log_id and log_id ~= "" and #log_id == 18 then -- Basic check for SF ID
      vim.cmd("tabnew | read !sfdx force:apex:log:get -i " .. log_id)
    else
      print("Could not find valid Log ID under cursor.".. log_id)
    end
  end, opts)

  -- Other Mappings
  map("n", "U", "<Cmd>ea 1f<CR>", { noremap = true }) -- Revert buffer (like :earlier 1f)
  map("n", "<leader>u", "<Cmd>UndotreeToggle<CR>", opts) -- Undotree
  map("n", "<leader>q", "<Cmd>q<CR>", opts) -- Quit
  map("n", "gQ", "gq", { noremap = true }) -- Prevent gq typo

  -- Detour mappings
  map("n", "<c-w>o", "<Cmd>Detour<CR>", opts)
  map("n", "<c-w>c", "<Cmd>DetourCurrentWindow<CR>", opts)
  map("n", "<c-w>b", "<Cmd>Detour<CR>:term bat --paging=always %<CR>a", opts) -- Open current file in bat popup

  -- FZF Keybindings
  map("n", "<C-p>", "<Cmd>Files!<CR>", opts)
  map("n", "<C-f>b", "<Cmd>Buffers<CR>", opts)
  map("n", "<C-f>s", "<Cmd>Snippets<CR>", opts)
  map("n", "<C-f>c", "<Cmd>BCommits!<CR>", opts)
  map("n", "<C-f>f", "<Cmd>BLines!<CR>", opts) -- Used Esc Esc: prefix before, Cmd is cleaner
  map("n", "<C-f>l", "<Cmd>Helptags!<CR>", opts)
  map("n", "<C-f>g", function() -- Grep for word under cursor
    vim.cmd([[ normal! "syiw ]]) -- Yank word into register s
    local word = vim.fn.getreg('s')
    if word and word ~= "" then
      vim.cmd('GGrepI ' .. word)
    end
  end, opts)
  map("n", "<C-f>m", "<plug>(fzf-maps-n)", opts) -- fzf-maps plugin
  map("n", "<C-f>r", "<plug>(ale_find_references)", opts) -- ALE find references
  map("n", "<C-f>t", "<Cmd>Filetypes!<CR>", opts)
  map("n", "<C-f>o", "<Cmd>Colors<CR>", opts)
  map("n", "<leader>x", "<Cmd>Commands<CR>", opts)


  -- FZF Insert Mode Completions (using expr = true)
  map("i", "<C-f>i", "fzf#vim#complete('cat ~/lib/.sldsicons.txt')", { expr = true, noremap = true })
  map("i", "<c-x><c-k>", "fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})", { expr = true, noremap = true })
  map("i", "<C-S>", "<Plug>(fzf-complete-wordnet)", { noremap = true }) -- fzf-wordnet plugin
  map("i", "<C-x>c", "fzf#vim#complete('cat ~/.sldsclasses.txt')", { expr = true, noremap = true })
  map("i", "<C-x>m", [[fzf#vim#complete({'source': 'cat schema.txt', 'reducer': { lines -> split(lines[0],' ')[0]}})]], { expr = true, noremap = true })
  map("n", "<C-y>", function() require('fzf_soql').fzf_soql() end, opts)
  map("i", "<C-x><C-y>", function() require('fzf_soql').fzf_soql() end, opts)

  -- ALE Keybindings
  map("n", "<C-w>i", "<Cmd>ALEToggleBuffer<CR>", opts)
  map("n", "<C-w>d", "<Cmd>ALEDetail<CR>", opts)
  map("n", "<leader>fo", "<Cmd>ALEFix<CR>", opts) -- Run fixers on demand

  -- Tagbar/Aerial Toggle
  map("n", "mm", "<Cmd>TagbarToggle<CR>", opts) -- Using Tagbar as per original 'mm' mapping

  -- Git Log Graph
  map("n", "<leader>g", '<Cmd>G log --all --decorate --graph --pretty=format:"%h%x09%an%x09%ad%x09%s"<CR>', opts)

  -- Disable arrow keys and scroll wheel in normal/insert mode
  map({ "n"}, "<Up>", "<nop>", opts)
  map({ "n"}, "<Down>", "<nop>", opts)
  map({ "n", "i" }, "<ScrollWheelUp>", "<nop>", opts)
  map({ "n", "i" }, "<S-ScrollWheelUp>", "<nop>", opts)
  map({ "n", "i" }, "<C-ScrollWheelUp>", "<nop>", opts)
  map({ "n", "i" }, "<ScrollWheelDown>", "<nop>", opts)
  map({ "n", "i" }, "<S-ScrollWheelDown>", "<nop>", opts)
  map({ "n", "i" }, "<C-ScrollWheelDown>", "<nop>", opts)
  map({ "n", "i" }, "<ScrollWheelLeft>", "<nop>", opts)
  map({ "n", "i" }, "<S-ScrollWheelLeft>", "<nop>", opts)
  map({ "n", "i" }, "<C-ScrollWheelLeft>", "<nop>", opts)
  map({ "n", "i" }, "<ScrollWheelRight>", "<nop>", opts)
  map({ "n", "i" }, "<S-ScrollWheelRight>", "<nop>", opts)
  map({ "n", "i" }, "<C-ScrollWheelRight>", "<nop>", opts)

  -- Sudo save
  map("c", "w!!", "w !sudo tee > /dev/null %", { noremap = true })

  -- Transparency Toggle
  map("n", "<leader>tt", toggle_transparent, opts)

  -- =============================================================================
  -- Plugin Configuration Variables (vim.g)
  -- =============================================================================

  -- UltiSnips
  vim.g.UltiSnipsExpandTrigger = "<tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
-- vim.g.UltiSnipsListSnippets = "<s-tab>" -- Conflicts with JumpBackward
vim.g.UltiSnipsUsePythonVersion = 3
vim.g.UltiSnipsSnippetDirectories = {"UltiSnips", vim.fn.expand("$HOME") .. "/.vim/mysnips"} -- Keep custom snips dir

-- CtrlP (If you decide to use it instead of fzf/telescope)
-- vim.g.ctrlp_map = '<c-p>'
-- vim.g.ctrlp_cmd = 'CtrlP'
-- vim.g.ctrlp_root_markers = {'.git','pom.xml','.ssh','node_modules'}
-- vim.g.ctrlp_custom_ignore = 'node_modules\\|DS_Store\\|git\\|src'

-- Netrw (File explorer) - Oil.nvim is used, so these might not be needed
vim.g.netrw_winsize = 25
vim.g.netrw_bufsettings = 'noma nomod nu nowrap ro nobl'
-- vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 3

-- ALE
vim.g.ale_info_default_mode = 'preview'
vim.g.ale_linters_explicit = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_sign_error = '>>'
vim.g.ale_sign_warning = '--'
vim.g.ale_floating_preview = 1
vim.g.ale_completion_tsserver_autoimport = 1 -- For TypeScript/JavaScript auto-imports
-- Paths for ALE tools (adjust as necessary)
vim.g.ale_apex_apexlsp_jarfile = '/Users/surajpillai/lib/apex-jorje-lsp.jar'
vim.g.ale_javascript_eslint_executable = 'eslint'
vim.g.ale_javascript_eslint_use_global = 1
vim.g.ale_java_google_java_format_executable = vim.fn.expand("~/.scripts/jformat.sh")
-- Linters per filetype
vim.g.ale_linters = {
  lwc = {'codeanalyzer'},
  javascript = {'eslint'},
  css = {'eslint'},
  html = {'eslint'},
  apex = {'codeanalyzer'}, 
  java = {'javalsp'}, -- Assuming nvim-lspconfig handles javac/checkstyle if needed
  jsw = {'eslint'},
  markdown = {'markdownlint'},
  rust = {'analyzer'}, -- rust-analyzer via nvim-lspconfig is preferred
  sh = {'shellcheck'},
  zsh = {'shellcheck'},
  typescript = {'tsserver'},
}
-- Fixers per filetype
vim.g.ale_fixers = {
  javascript = {'prettier', 'eslint'}, -- Add eslint if you use it for fixing
  lwc = {'prettier'},
  css = {'prettier'},
  apex = {'prettier'},
  html = {'prettier'},
  jsw = {'prettier'},
  typescript = {'prettier', 'eslint'},
  typescriptreact = {'prettier', 'eslint'},
  json = {'jq', 'prettier'}, -- Added prettier for json
  python = {'black', 'isort'}, -- Added isort commonly used with black
  java = {'google_java_format'},
  markdown = {'prettier'},
  rust = {'rustfmt', 'trim_whitespace', 'remove_trailing_lines'},
  sh = {'shfmt'},
  zsh = {'shfmt'},
  xml = {'tidy', 'prettier'}, -- Added prettier for xml
  nix = {'nixpkgs-fmt'},
}
-- PMD rules (conditional load)
if vim.fn.filereadable('config/pmd-rules.xml') == 1 then
  vim.g.ale_apex_pmd_options = " -R config/pmd-rules.xml"
end


vim.g.ale_sh_shfmt_options = '-i 2 -ci -sr'

-- Float Preview (for ncm2/float-preview.nvim)
vim.g['float_preview#docked'] = 1 -- Use brackets for '#'

-- Airline
vim.g['airline#extensions#whitespace#symbol'] = '!' -- Use brackets for '#'
-- Statusline function for SFDX (Needs testing in Lua context)
-- vim.g.airline_section_a = '%{luaeval("require(\'utils\').statusline_sfdx()")}' -- Example if moved to a Lua module

-- Tagbar Apex Configuration
vim.g.tagbar_type_apex = {
  ctagstype = 'java',
  kinds = {
    'p:packages:1:0',
    'f:fields:0:0',
    'g:enum types',
    'e:enum constants:0:0',
    'i:interfaces',
    'c:classes',
    'm:methods',
    '?:unknown',
  },
}

-- FZF Actions (keeping Vimscript function for simplicity)
-- Ensure the Vimscript function is defined somewhere accessible or define it here
vim.cmd([[
  function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
  endfunction

  let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
]])


-- Copilot
vim.g.copilot_assume_mapped = true -- Let copilot know other mappings might exist
vim.g.copilot_no_tab_map = false    -- Disable default Tab mapping
vim.g.copilot_filetypes = {        -- Disable copilot for specific filetypes
  xml = false,
  -- Add other filetypes if needed
}
vim.api.nvim_set_keymap('i', '<C-i>', "copilot#Accept('\\<CR>')", { silent = true, expr = true })


-- =============================================================================
-- Load Lua Modules (After plugins are set up)
-- =============================================================================
-- Make sure these files exist in ~/.config/nvim/lua/
require 'basic' -- Careful, this might conflict with init.lua itself! Rename if needed. e.g., require('core_init')
require 'keymaps' -- Load your custom keymaps defined in lua/keymaps.lua
-- require 'copilot_ls' -- Uncomment if you have this file
-- require 'theme' -- Uncomment if you have this file (theme usually set via colorscheme cmd)
require 'lspconf' -- Load LSP configurations from lua/lsp.lua
require 'dapconfig' -- Load DAP configurations from lua/dapconfig.lua
require 'parallelpopup'
require 'soql_ls'
require 'macros'
require 'copilot_chat'

require 'nixdlspconf' -- Load Nix LSP configurations

require 'nonelsconfig'

require('sfcommands').setup() -- Load Salesforce specific commands

require 'lwc_ls'

require 'apex_ls'



-- Load your custom vertex module if it's local and not a plugin
pcall(require, 'vertex') -- Use pcall to avoid errors if file doesn't exist

-- =============================================================================
-- Final Setup
-- =============================================================================
-- Apply colorscheme (should be done by lazy.nvim priority or here)
vim.cmd('colorscheme ' .. original_colorscheme) -- Set the default colorscheme
vim.g.colors_name = original_colorscheme -- Store it for transparency toggle

-- Apply transparency on startup (matches original behavior)
make_transparent()
