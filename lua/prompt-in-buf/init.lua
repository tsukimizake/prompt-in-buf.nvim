local M = {}

local config = {
  buffer_setup = nil
}

local function create_popup_buffer()
  local original_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()
  local original_cursor = vim.api.nvim_win_get_cursor(original_win)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Prompt Buffer ',
    title_pos = 'center',
  })

  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].buftype = 'nofile'
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  -- Setup buffer if function is provided
  if config.buffer_setup and type(config.buffer_setup) == 'function' then
    config.buffer_setup(buf)
  end

  function M.insert_to_original()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, '\n')

    vim.api.nvim_win_close(win, true)
    vim.api.nvim_set_current_win(original_win)
    vim.api.nvim_win_set_cursor(original_win, original_cursor)

    if content and content ~= '' then
      local cursor_line = original_cursor[1]
      local cursor_col = original_cursor[2]

      vim.api.nvim_buf_set_text(original_buf, cursor_line - 1, cursor_col, cursor_line - 1, cursor_col,
        vim.split(content, '\n'))
    end
  end

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_set_current_win(original_win)
  end, { buffer = buf, noremap = true, silent = true })

  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })

  vim.cmd('startinsert')
end

function M.open_prompt_buffer()
  create_popup_buffer()
end

function M.setup(opts)
  opts = opts or {}

  -- Set buffer setup function
  if opts.buffer_setup then
    config.buffer_setup = opts.buffer_setup
  end

  vim.api.nvim_create_user_command('PromptInBuf', function()
    M.open_prompt_buffer()
  end, {})

  if opts.keymap then
    vim.keymap.set('n', opts.keymap, M.open_prompt_buffer, { noremap = true, silent = true })
  end
end

return M

