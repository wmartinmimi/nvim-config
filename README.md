# nvim-config

## Description

This is my own personal nvim config.
I keep this as backup in case I wiped my config.

Intended for termux but may work on others as well.

You are welcomed to fork and use my config.

There is no guarantee of stability or compatibility.
Everything may change at anytime.

## Screenshot

![Example](example.jpg)

## Features

- modernish look (with catppuccin)
- autocompletion with lsp
- easy lsp install and setup with mason.nvim
- git interface for commits and conflict managing
- autosave
- telescope.nvim
- quick word jumping with hop.nvim

## Installing Lsps
```<ESC>:Mason<ENTER>``` to enter Mason.

Select lsp and press ```i``` to install.
Lsp will be automatically setup.

## Shortcuts

- ```tt```: opens Telescope.nvim
- ```ff```: opens nvim-tree
- ```cf```: formats code via gg=G
- ```Alt-/```: word jump

## Installation

```bash
mv ~/.config/nvim ~/.config/nvim.old
git clone https://github.com/wmartinmimi/nvim-config ~/.config/nvim
```

If Packer shows error on first install, reopen nvim and run ```:PackerSync``` again.

## Requires

- Nerdfont

Download a nerdfont, paste in ~/.termux, and rename to ```font.ttf```.

## Command to exit nvim

```<ESC>:qa<ENTER>```

## License

MIT Licensed
