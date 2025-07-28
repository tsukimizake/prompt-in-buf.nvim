# prompt-in-buf.nvim

A Neovim plugin that opens a popup buffer with completion support for writing prompts, especially useful when using AI tools in terminal mode where normal completion isn't available. Supports both regular buffers and terminal buffers with seamless integration.

## Features

- **Universal Buffer Support**: Works seamlessly with both regular buffers and terminal buffers
- **Popup Interface**: Opens a centered popup buffer with markdown filetype and syntax highlighting
- **Full Completion Support**: Unlike terminal mode, provides complete nvim-cmp integration
- **Multiple Insert Methods**:
  - Press `<Enter>` in normal mode
  - Use `:wq`, `:Wq`, or `:WQ` commands
  - Use `<C-c>` in insert mode (customizable)
- **Smart Terminal Integration**: Automatically sends text to terminal via channel and returns to insert mode
- **Easy Cancellation**: Press `<Esc>` to close without inserting
- **Auto-cleanup**: Automatically closes when leaving the buffer
- **Highly Customizable**: User-defined buffer setup for additional keymaps and completion sources

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
1. **Open popup**: Creates a centered popup buffer with markdown syntax highlighting
2. **Start in insert mode**: Ready for immediate text input
3. **Provide full completion**: All nvim-cmp sources work (unlike terminal mode)
4. **Smart insertion**: Content is inserted differently based on buffer type:
   - **Regular buffers**: Text inserted at cursor position
   - **Terminal buffers**: Text sent via terminal channel, returns to insert mode
5. **Multiple completion methods**:
   - `<Enter>` in normal mode
   - `:wq`, `:Wq`, or `:WQ` commands
   - `<C-c>` in insert mode (customizable)
6. **Easy cancellation**: Press `<Esc>` to close without inserting

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
  end
})
```

### Options

- `keymap` (string, optional): Keymap to open the prompt buffer
- `buffer_setup` (function, optional): Custom function to setup the popup buffer with additional keymaps, commands, and completion sources. The function receives the buffer number as its first argument.

### Use Cases

- **AI Tool Integration**: Perfect for tools like Claude Code, Aider, or other AI assistants in terminal mode
- **Terminal Workflows**: Write complex commands or prompts with full completion support
- **Quick Notes**: Rapidly capture thoughts or ideas with markdown formatting
- **Code Snippets**: Write and insert code with language server completion
