# prompt-in-buf.nvim

A Neovim plugin that opens a popup buffer with completion support for writing prompts, especially useful when using AI tools in terminal mode where normal completion isn't available.

## Features

- Opens a centered popup buffer with markdown filetype
- Full completion support (unlike terminal mode)
- Multiple ways to insert content:
  - Press `<Enter>` in normal mode
  - Use `:wq`, `:Wq`, or `:WQ` commands
  - Use `<C-c>` in insert mode
- Press `<Esc>` to close without inserting
- Automatically closes when leaving the buffer
- Customizable buffer setup for additional keymaps and completion sources

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  dir = "/path/to/prompt-in-buf-nvim", -- or your git repository
  config = function()
    require('prompt-in-buf').setup({
      keymap = '<leader>p' -- optional: set a keymap to open the prompt buffer
    })
  end
}
```

## Usage

- Command: `:PromptInBuf`
- Or use the configured keymap (default: none)

The plugin will:
1. Open a popup buffer in the center of the screen
2. Set filetype to markdown for syntax highlighting
3. Start in insert mode
4. Allow you to write with full completion support
5. Insert content using multiple methods:
   - `<Enter>` in normal mode
   - `:wq`, `:Wq`, or `:WQ` commands
   - `<C-c>` in insert mode
6. Press `<Esc>` to cancel and close the popup

## Configuration

```lua
require('prompt-in-buf').setup({
  keymap = '<leader>p', -- Set a keymap to quickly open the prompt buffer
  buffer_setup = function(buf)
    -- Custom buffer setup function (optional)
    -- Example: Add custom keymaps and completion sources
    vim.keymap.set('n', '<CR>', function()
      require('prompt-in-buf').insert_to_original()
    end, { buffer = buf, noremap = true, silent = true })
    
    vim.keymap.set('i', '<C-c>', function()
      require('prompt-in-buf').insert_to_original()
    end, { buffer = buf, noremap = true, silent = true })
    
    -- Add :wq commands
    vim.api.nvim_buf_call(buf, function()
      vim.cmd('cabbrev <buffer> wq lua require("prompt-in-buf").insert_to_original()')
      vim.cmd('cabbrev <buffer> Wq lua require("prompt-in-buf").insert_to_original()')
      vim.cmd('cabbrev <buffer> WQ lua require("prompt-in-buf").insert_to_original()')
    end)
    
    -- Setup completion sources
    local cmp = require('cmp')
    cmp.setup.buffer({
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
      })
    }, buf)
  end
})
```

### Options

- `keymap` (string, optional): Keymap to open the prompt buffer
- `buffer_setup` (function, optional): Custom function to setup the popup buffer with additional keymaps, commands, and completion sources