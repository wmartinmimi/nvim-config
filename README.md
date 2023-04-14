# nvim-config

## Description
This is my own personal nvim config.
I keep this as backup in case I wiped my config.

You are welcomed to fork and use my config.

## Features
- modernish look (with catppuccin)
- autocompletion with lsp
- git interface for commits and conflict managing
- autosave
- telescope.nvim
- quick word jumping with hop.nvim

## Shortcuts
```tt```: opens Telescope.nvim
```ff```: opens nvim-tree
```cf```: formats code via gg=G
```Alt-/```: word jump

## Installation
```bash
mv ~/.config/nvim ~/.config/nvim.old
git clone https://github.com/wmartinmimi/nvim-config ~/.config/nvim
nvim +PackerSync
```
