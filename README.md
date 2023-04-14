# nvim-config

## Description

This is my own personal bootstrapped nvim config.
I keep this as backup in case I wiped my config.

Intended for termux but may work on others as well.

You are welcomed to fork and use my config.

## Screenshot

![Example](example.jpg)

## Features

- modernish look (with catppuccin)
- autocompletion with lsp
- git interface for commits and conflict managing
- autosave
- telescope.nvim
- quick word jumping with hop.nvim

## Languages lsps auto installed and setup

- c/c++, anything that clang supports
- html, css, javascript, typescript
- java
- lua

## Shortcuts

- ```tt```: opens Telescope.nvim
- ```ff```: opens nvim-tree
- ```cf```: formats code via gg=G
- ```Alt-/```: word jump

## Installation

```bash
# install required packages
apt install neovim git 
# install lsp packages
apt install clang rust-analyzer lua-language-server nodejs-lts
# auto backup old config
mv ~/.config/nvim ~/.config/nvim.old
# clone the required config files
git clone https://github.com/wmartinmimi/nvim-config ~/.config/nvim
# auto start nvim for auto setup
nvim +PackerSync
```

## Command to exit nvim

```<ESC>:qa<ENTER>```

## License

MIT Licensed
