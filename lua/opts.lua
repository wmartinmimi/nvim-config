local opt = vim.opt
local g = vim.g
local map = vim.api.nvim_set_keymap

opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.lazyredraw = true

g.do_filetype_lua = true
g.did_load_filetypes = false

map('n', 'cf', 'gg=G<CR>', {})
