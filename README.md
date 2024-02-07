# nvim-config

## Description

This is my own personal nvim config.
I keep this as backup in case I wiped my config.

Intended for personal use (in termux) but may work for others as well.

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
- quick word jumping with leap.nvim
- ai autocompletion via codeium
- markdown preview

## Installing Lsps

`<ESC>:Mason<ENTER>` to enter Mason.

Select lsp and press `i` to install.
Lsp will be automatically setup.

## Preview Markdown

`<ESC>:MarkdownPreview<ENTER>` to start preview

`<ESC>:MarkdownPreviewStop<ENTER>` to stop preview

`<ESC>:MarkdownPreviewToggle<ENTER>` to toggle preview

## Shortcuts

- `tt`: opens Telescope.nvim
- `ff`: opens nvim-tree
- `cf`: formats code via `gg=G`
- `Alt-/`: word jump
- `Alt-Right`: accept codeium autocomplete
- `Alt-Up`: switch to next codeium autocomplete
- `Alt-Down`: switch to previous codeium autocomplete
- `Alt-Left`: cancel normal autocomplete

## Installation

```bash
mv ~/.config/nvim ~/.config/nvim.old
git clone https://github.com/wmartinmimi/nvim-config ~/.config/nvim
```

If Lazy shows error on first install, reopen nvim, run `:Lazy`, and run update (U).

If codeium complains about `^M`, run `fromdos` in the files with errors to convert from `crlf` to `lf`.

## Requires

- Nerdfont

Download a nerdfont, paste in ~/.termux, and rename to `font.ttf`.

- Ripgrep

Download ripgrep for fast regex.

- Nodejs

Download nodejs with `apt install nodejs`

```bash
apt install ripgrep
```

## Command to exit nvim

`<ESC>:qa<ENTER>`

## License

MIT Licensed
