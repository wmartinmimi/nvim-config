local map = vim.api.nvim_set_keymap

map('n', 'cf', 'gg=G<CR>', {})
map('n', 'tt', ':Telescope<CR>', {})
map('n', 'ff', ':NvimTreeToggle<CR>', {})

local function leap()
  local focusable_windows_on_tabpage = vim.tbl_filter(
    function (win) return vim.api.nvim_win_get_config(win).focusable end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  require('leap').leap { target_windows = focusable_windows_on_tabpage }
end

vim.keymap.set('', '<M-/>', leap)
vim.keymap.set('i', '<M-/>', leap)
