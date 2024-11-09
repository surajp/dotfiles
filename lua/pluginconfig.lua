-- This module contains a number of default definitions
local rainbow_delimiters = require 'rainbow-delimiters'

---@type rainbow_delimiters.config
vim.g.rainbow_delimiters = {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
    },
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
    },
    priority = {
        [''] = 110,
        lua = 210,
    },
    highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
    },
}

-- buffer nav
local snipe = require("snipe")
snipe.config = {
  ui = {
    max_width = -1, -- -1 means dynamic width
    -- Where to place the ui window
    -- Can be any of "topleft", "bottomleft", "topright", "bottomright", "center", "cursor" (sets under the current cursor pos)
    position = "topleft",
  },
  hints = {
    -- Charaters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
    dictionary = "sadflewcmpghio",
  },
  navigate = {
    -- When the list is too long it is split into pages
    -- `[next|prev]_page` options allow you to navigate
    -- this list
    next_page = "J",
    prev_page = "K",

    -- You can also just use normal navigation to go to the item you want
    -- this option just sets the keybind for selecting the item under the
    -- cursor
    under_cursor = "<cr>",

    -- In case you changed your mind, provide a keybind that lets you
    -- cancel the snipe and close the window.
    cancel_snipe = "qq",
  },
  -- Define the way buffers are sorted by default
  -- Can be any of "default" (sort buffers by their number) or "last" (sort buffers by last accessed)
  sort = "default"
}
