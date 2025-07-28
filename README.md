# prompt-in-buf.nvim

A Neovim plugin that opens a popup buffer with completion support for writing prompts, especially useful when using AI tools in terminal mode where normal completion isn't available.

## Features

- Opens a centered popup buffer with markdown filetype
- Full completion support (unlike terminal mode)
- Press `<Enter>` in normal mode to insert content into original buffer
- Press `<Esc>` to close without inserting
- Automatically closes when leaving the buffer

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
5. Press `<Enter>` in normal mode to insert the content at your cursor position
6. Press `<Esc>` to cancel and close the popup

## Configuration

```lua
require('prompt-in-buf').setup({
  keymap = '<leader>p' -- Set a keymap to quickly open the prompt buffer
})
```