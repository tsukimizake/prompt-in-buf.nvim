local M = {}

local config = {
  buffer_setup = nil
}

-- Helper function to insert content to different buffer types
local function insert_content_to_buffer(content, target_buf, target_win, target_cursor, is_terminal)
  if not content or content == '' then
    return
  end

  if is_terminal then
    -- Send text to terminal via channel
    local job_id = vim.bo[target_buf].channel
    if job_id and job_id > 0 then
      vim.fn.chansend(job_id, content)
    else
      vim.notify('Terminal channel not available', vim.log.levels.WARN)
    end
  else
    -- Insert text to regular buffer
    local cursor_line = target_cursor[1]
    local cursor_col = target_cursor[2]
    local content_lines = vim.split(content, '\n')

    -- Ensure target buffer is still valid
    if vim.api.nvim_buf_is_valid(target_buf) then
      vim.api.nvim_buf_set_text(target_buf, cursor_line - 1, cursor_col, cursor_line - 1, cursor_col, content_lines)
    end
  end
end

local function create_popup_buffer()
  local original_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()
  local original_cursor = vim.api.nvim_win_get_cursor(original_win)
  local is_terminal = vim.bo[original_buf].buftype == 'terminal'

  -- Calculate popup dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create popup buffer and window
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

  -- Set buffer options
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].buftype = 'nofile'
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  vim.cmd('startinsert')

  -- Apply user-defined buffer setup
  if config.buffer_setup and type(config.buffer_setup) == 'function' then
    config.buffer_setup(buf)
  end

  -- Define insert function with closure over local variables
  function M.insert_to_original()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, '\n')

    -- Close popup and return to original window
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    if vim.api.nvim_win_is_valid(original_win) then
      vim.api.nvim_set_current_win(original_win)
      vim.api.nvim_win_set_cursor(original_win, original_cursor)
    end

    -- Insert content to target buffer
    insert_content_to_buffer(content, original_buf, original_win, original_cursor, is_terminal)
  end

  -- Helper function to close popup and return to original buffer
  local function close_popup()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_win_is_valid(original_win) then
      vim.api.nvim_set_current_win(original_win)
    end
  end

  -- Set up escape key to close without inserting
  vim.keymap.set('n', '<Esc>', close_popup, { buffer = buf, noremap = true, silent = true })

  -- Auto-close when leaving buffer
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    once = true,
    callback = close_popup,
  })
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
