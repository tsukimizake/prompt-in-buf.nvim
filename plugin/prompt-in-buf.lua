if vim.g.loaded_prompt_in_buf then
  return
end
vim.g.loaded_prompt_in_buf = 1

require('prompt-in-buf').setup()

