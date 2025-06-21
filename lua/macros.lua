-- set macro
local ctrl_r = vim.api.nvim_replace_termcodes('<C-R>', true, true, true)
local enter = vim.api.nvim_replace_termcodes('<CR>', true, true, true)

local macros_group = vim.api.nvim_create_augroup("MacrosSetup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = macros_group,
    pattern = { "javascript", "typescript" },
    callback = function()
        vim.fn.setreg("l", 'yiwoconsole.log("' .. ctrl_r .. '": ",' .. ctrl_r .. '");kj:w' .. enter)
    end,
})
