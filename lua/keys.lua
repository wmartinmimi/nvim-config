local map = vim.api.nvim_set_keymap

map('n', 'cf', 'gg=G<CR>', {})
map('n', 'tt', ':Telescope<CR>', {})
map('', '<M-/>', '<Cmd>:HopWord<CR>', {})
map('i', '<M-/>', '<Cmd>:HopWord<CR>', {})
map('n', 'ff', ':NvimTreeToggle<CR>', {})
