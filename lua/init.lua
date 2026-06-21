
-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv('PREFIX') or 'nil',
  'termux'
)

-- LSP --
local servers = {
  clangd = {
    cmd = { 'clangd', '--ranking-model=decision_forest' },
  },
  tinymist = {
    settings = {
      completion = {
        triggerOnSnippetPlaceholders = true,
      },
      lint = {
        enabled = true,
      },
    },
  },
  zls = {
    settings = {
      -- required until: https://github.com/zigtools/zls/issues/2617
      build_on_save_args = { '-fincremental' },
    }
  },
}

--------------------------------
--- OPTIONS
--------------------------------

-- file encodings
vim.opt.encoding = 'utf8'
vim.opt.fileformat = 'unix'

-- editor appearances
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.linebreak = true
vim.opt.scrolloff = 999
vim.opt.modeline = false

vim.opt.termguicolors = true
vim.opt.lazyredraw = true

vim.opt.expandtab = true

-- dangerous, local project execution
vim.opt.exrc = true
vim.opt.secure = true


if isTermux then
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
else
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
end

-- disable providers, as we don't use them and they slow down nvim
vim.g.loaded_python3_provider = true
vim.g.loaded_ruby_provider = true
vim.g.loaded_perl_provider = true
vim.g.loaded_node_provider = true

--------------------------------
--- PLUGINS
--------------------------------

-- all plugins
vim.pack.add({
  { src = 'https://github.com/delphinus/auto-cursorline.nvim' },
  { src = 'https://github.com/okuuva/auto-save.nvim' },
  { src = 'https://github.com/romgrk/barbar.nvim' }, -- depends: nvim-web-devicons
  { src = 'https://github.com/erooke/blink-cmp-latex' },
  { src = 'https://github.com/ribru17/blink-cmp-spell' },
  { src = 'https://github.com/moyiz/blink-emoji.nvim' },
  { src = 'https://github.com/MahanRahmati/blink-nerdfont.nvim' },
  { src = 'https://github.com/saghen/blink.cmp',                           version = vim.version.range '1.*' },
  { src = 'https://github.com/folke/flash.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/nmac427/guess-indent.nvim' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  { src = 'https://github.com/tzachar/local-highlight.nvim' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },      -- depends: nvim-web-devicons
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' }, -- depends: nvim-lspconfig, mason.nvim
  { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/nacro90/numb.nvim' },
  { src = 'https://github.com/catppuccin/nvim',                            name = 'catppuccin' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/igorlfs/nvim-dap-view' },
  { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' }, -- depends: nvim-web-devicons
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/hedyhli/outline.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/stevearc/quicker.nvim' },
  { src = 'https://gitlab.com/HiPhish/rainbow-delimiters.nvim' },
  { src = 'https://github.com/sphamba/smear-cursor.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' }, -- depends: plenary.nvim, trouble.nvim
  { src = 'https://github.com/wmartinmimi/todo-highlight.nvim' },
  { src = 'https://github.com/folke/trouble.nvim' },            -- depends: nvim-web-devicons
  { src = 'https://github.com/chomosuke/typst-preview.nvim' },
  { src = 'https://github.com/mg979/vim-visual-multi' },
}, { load = nil })

-- loaders
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    -- delay until UI drawn
    vim.schedule(function()
      vim.api.nvim_exec_autocmds('User', { pattern = 'TooLazy' })
    end)
  end
})

local function load_once(name, cb)
  local pack = require(name)
  if not pack._configured then
    cb()
    pack._configured = true
  end
end

local function lazy(cb)
  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'TooLazy',
    callback = cb
  })
end

local function lazy_cmd(cmds, cb)
  for _, cmd in ipairs(cmds) do
    local loaded = false
    local function full_callback()
      if not loaded then
        for _, c in ipairs(cmds) do
          vim.api.nvim_del_user_command(c)
        end
        cb()
        loaded = true
      end
    end

    vim.api.nvim_create_user_command(cmd, function(opts)
      full_callback()
      vim.cmd(cmd .. ' ' .. (opts.args or ''))
    end, {
      nargs = '*',
      complete = function(_, c, _)
        full_callback()
        return vim.fn.getcompletion(c, 'cmdline')
      end
    })
  end
end

local function lazy_event(events, cb)
  vim.api.nvim_create_autocmd(events, {
    once = true,
    callback = cb,
  })
end

-- color scheme
vim.cmd.packadd 'catppuccin'
require 'catppuccin'.setup {
  favour = 'auto',
  transparent_background = not isTermux,
  term_colors = true,
  no_italic = true,
  custom_highlights = function(colors)
    return {
      LineNr = { fg = colors.overlay0 },
      ['@comment.error'] = { fg = colors.red, bg = 'NONE', style = { 'bold' } },
      ['@comment.warning'] = { fg = colors.yellow, bg = 'NONE', style = { 'bold' } },
      ['@comment.hint'] = { fg = colors.blue, bg = 'NONE', style = { 'bold' } },
      ['@comment.todo'] = { fg = colors.flamingo, bg = 'NONE', style = { 'bold' } },
      ['Todo'] = { fg = colors.flamingo, bg = 'NONE', style = { 'bold' } },
      ['@comment.note'] = { fg = colors.rosewater, bg = 'NONE', style = { 'bold' } },
    }
  end,
}
vim.cmd.colorscheme 'catppuccin'


-- undo
vim.opt.undofile = true
vim.keymap.set('n', 'tu', function()
  vim.cmd.packadd 'nvim.undotree'
  require 'undotree'.open()
end)

-- tree sitter
local function load_treesitter(args)
  local parser = vim.treesitter.get_parser(args.buf)
  if parser then
    vim.treesitter.start(args.buf)
    vim.api.nvim_exec_autocmds('User', {
      pattern = 'TSBufAttach',
      data = { buf = args.buf, lang = parser:lang() },
    })
  end
end

vim.api.nvim_create_autocmd('FileType', {
  callback = load_treesitter
})
vim.api.nvim_create_user_command('TSReload', load_treesitter, {})

local function on_ts_attach(cb)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'TSBufAttach',
    callback = cb
  })
end


-- guess indent
vim.cmd.packadd 'guess-indent.nvim'
require 'guess-indent'.setup {}


-- tree sitter installer
lazy_cmd({ 'TSInstall', 'TSInstallFromGrammar', 'TSUpdate', 'TSUninstall', 'TSLog' }, function()
  vim.cmd.packadd 'nvim-treesitter'
  require 'nvim-treesitter.config'.setup {}
end)


-- text objects
lazy(function()
  local function require_ts(module)
    load_once('nvim-treesitter-textobjects', function()
      vim.cmd.packadd 'nvim-treesitter-textobjects'
      require 'nvim-treesitter-textobjects'.setup {
        select = { lookahead = true },
      }
    end)
    return require('nvim-treesitter-textobjects.' .. module)
  end

  local function ts_select_io(key, obj)
    vim.keymap.set({ 'x', 'o' }, 'a' .. key, function()
      require_ts 'select'.select_textobject(obj .. '.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'i' .. key, function()
      require_ts 'select'.select_textobject(obj .. '.inner', 'textobjects')
    end)
  end

  ts_select_io('f', '@function')
  ts_select_io('c', '@class')
  ts_select_io('i', '@conditional')
  ts_select_io('l', '@loop')
  ts_select_io('/', '@comment')
  ts_select_io('a', '@parameter')

  vim.keymap.set({ 'x', 'o' }, 'as', function()
    require_ts 'select'.select_textobject('@local.scope', 'locals')
  end)
  vim.keymap.set({ 'x', 'o' }, 'is', function()
    require_ts 'select'.select_textobject('@fold', 'folds')
  end)

  vim.keymap.set('n', '<leader>]a', function()
    require_ts 'swap'.swap_next '@parameter.inner'
  end)
  vim.keymap.set('n', '<leader>[a', function()
    require_ts 'swap'.swap_previous '@parameter.inner'
  end)

  local function ts_goto(key, obj, scm)
    vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key:upper(), function()
      require_ts 'move'.goto_next_end(obj, scm)
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key, function()
      require_ts 'move'.goto_next_start(obj, scm)
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key:upper(), function()
      require_ts 'move'.goto_previous_end(obj, scm)
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key, function()
      require_ts 'move'.goto_previous_start(obj, scm)
    end)
  end

  local function ts_goto_io(key, obj)
    vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key:upper(), function()
      require_ts 'move'.goto_next_end(obj .. '.inner', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key, function()
      require_ts 'move'.goto_next_start(obj .. '.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key:upper(), function()
      require_ts 'move'.goto_previous_end(obj .. '.inner', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key, function()
      require_ts 'move'.goto_previous_start(obj .. '.outer', 'textobjects')
    end)
  end

  ts_goto_io('f', '@function')
  ts_goto_io('c', '@class')
  ts_goto_io('i', '@conditional')
  ts_goto_io('l', '@loop')
  ts_goto_io('/', '@comment')
  ts_goto_io('a', '@parameter')

  -- ts_goto('s', '@local.scope', 'locals')
  ts_goto('z', '@fold', 'folds')

  vim.keymap.set({ 'n', 'x', 'o' }, ';', require_ts 'repeatable_move'.repeat_last_move_next)
  vim.keymap.set({ 'n', 'x', 'o' }, ',', require_ts 'repeatable_move'.repeat_last_move_previous)
end)


-- todo highlight
on_ts_attach(function()
  load_once('todo-highlight', function()
    vim.cmd.packadd 'todo-highlight.nvim'
    require 'todo-highlight'.setup {
      ts_query = function(ft)
        if ft == 'typst' then
          return '[(comment) (text)] @comment'
        end
        return nil
      end,
      contextless = function(ft)
        return ft == 'markdown'
      end,
    }
  end)
  require 'todo-highlight'.highlight()
end)


-- flash
local function load_flash()
  load_once('flash', function()
    vim.cmd.packadd 'flash.nvim'
    require 'flash'.setup {
      modes = {
        treesitter = {
          highlight = {
            backdrop = true,
          },
        },
      },
    }
  end)
end

vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  load_flash()
  require('flash').jump()
end, { desc = 'Flash' })

vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  load_flash()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })

vim.keymap.set('o', 'r', function()
  load_flash()
  require('flash').remote()
end, { desc = 'Remote Flash' })

vim.keymap.set({ 'o', 'x' }, 'R', function()
  load_flash()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })

vim.keymap.set('c', '<c-s>', function()
  load_flash()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })


-- UI
vim.cmd.packadd 'nvim-web-devicons'

vim.cmd.packadd 'barbar.nvim'
require 'barbar'.setup {}

lazy(function()
  vim.cmd.packadd 'lualine.nvim'
  require 'lualine'.setup {}
end)


-- trouble
local function load_trouble()
  load_once('trouble', function()
    vim.cmd.packadd 'trouble.nvim'
    require 'trouble'.setup {}
  end)
end
vim.keymap.set('n', 'cd', function()
  load_trouble()
  require 'trouble'.toggle { mode = 'diagnostics' }
end, { desc = 'Opens trouble' })


-- telescope
local function load_telescope()
  load_once('telescope', function()
    vim.cmd.packadd 'plenary.nvim'
    load_trouble()
    vim.cmd.packadd 'telescope.nvim'

    local telescope = require('telescope')
    local trouble = require('trouble.sources.telescope')
    telescope.setup {
      defaults = {
        mappings = {
          i = { ['<c-t>'] = trouble.open },
          n = { ['<c-t>'] = trouble.open },
        },
      },
    }
  end)
end

lazy_cmd({ 'Telescope' }, load_telescope)

vim.keymap.set('n', 'tt', function()
  load_telescope()
  vim.cmd 'Telescope'
end, { desc = 'Opens telescope' })

vim.keymap.set('n', '<leader>lf', function()
  load_telescope()
  require 'telescope.builtin'.lsp_document_symbols {
    symbols = 'function'
  }
end, { desc = 'List functions in file' })


-- quicker nvim
vim.api.nvim_create_autocmd('FileType', {
  once = true,
  pattern = 'qf',
  callback = function()
    vim.cmd.packadd 'quicker.nvim'
    require 'quicker'.setup {}
  end
})


-- nvim tree
local function load_nvim_tree()
  load_once('nvim-tree', function()
    vim.cmd.packadd 'nvim-tree.lua'
    require 'nvim-tree'.setup {}
  end)
end

vim.keymap.set('n', 'ff', function()
  load_nvim_tree()
  vim.cmd 'NvimTreeToggle'
end, { desc = 'opens nvim-tree' })


-- ibl
lazy(function()
  vim.cmd.packadd 'indent-blankline.nvim'
  require 'ibl'.setup {
    scope = {
      show_start = false,
      show_end = false,
    }
  }
end)


-- rainbow delimiters
on_ts_attach(function()
  vim.cmd.packadd 'rainbow-delimiters.nvim'
  require 'rainbow-delimiters'.enable()
end)


-- auto pairs
lazy_event({ 'InsertEnter' }, function()
  vim.cmd.packadd 'nvim-autopairs'
  require 'nvim-autopairs'.setup {
    check_ts = true,
  }
end)


-- local highlight
vim.cmd.packadd 'local-highlight.nvim'
require 'local-highlight'.setup {
  hlgroup = '@text.underline',
  cw_hlgroup = '@text.underline',
  insert_mode = true,
  debounce_timeout = 100,
  animate = false,
}


-- blink
vim.opt.spell = true
vim.opt.spelllang = { 'en_gb', 'en_us' }
vim.api.nvim_set_hl(0, 'SnippetTabstop', {})
vim.api.nvim_set_hl(0, 'SnippetTabstopActive', {})

lazy_event({ 'InsertEnter', 'CmdlineEnter' }, function()
  vim.cmd.packadd 'blink.cmp'
  vim.cmd.packadd 'blink-emoji.nvim'
  vim.cmd.packadd 'blink-nerdfont.nvim'
  vim.cmd.packadd 'blink-cmp-latex'
  vim.cmd.packadd 'blink-cmp-spell'

  require 'blink.cmp'.setup {
    cmdline = {
      keymap = { preset = 'inherit' },
      completion = { menu = { auto_show = true } },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      ghost_text = { enabled = true },
      list = { selection = {
        preselect = function(_)
          return not require 'blink.cmp'.snippet_active { direction = 1 }
        end,
      } },
      menu = {
        direction_priority = { 'n', 's' },
        draw = {
          columns = {
            { 'label',     'label_description' },
            { 'kind_icon', 'source_name',      gap = 1 },
          },
        },
      },
      trigger = {
        show_on_backspace_in_keyword = true,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'emoji', 'nerdfont', 'latex', 'spell' },
      providers = {
        emoji = {
          name = 'Emoji',
          module = 'blink-emoji',
          score_offset = -200,
          opts = { trigger = ':' },
        },
        nerdfont = {
          name = 'Nerd',
          module = 'blink-nerdfont',
          score_offset = -200,
          opts = { trigger = ':' },
        },
        latex = {
          name = 'Latex',
          module = 'blink-cmp-latex',
          score_offset = -200,
          opts = { insert_command = true },
        },
        spell = {
          name = 'Spell',
          module = 'blink-cmp-spell',
          score_offset = -400,
          enabled = function()
            return vim.opt.spell
          end,
          opts = { use_cmp_spell_sorting = true, keep_all_entries = true, max_entries = 10 },
        },
        buffer = {
          score_offset = -600,
        }
      },
    },
    keymap = {
      preset = 'super-tab',
      ['<M-Left>'] = { 'cancel' },
      ['<M-Right>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        'snippet_forward',
        'fallback'
      },
    },
  }
end)


-- mason
local function load_mason()
  load_once('mason', function()
    vim.cmd.packadd 'mason.nvim'
    require 'mason'.setup {}
  end)
end


-- lsp config
lazy(function()
  load_mason()
  vim.cmd.packadd 'nvim-lspconfig'
  vim.cmd.packadd 'mason-lspconfig.nvim'

  require 'mason-lspconfig'.setup {}

  for server, config in pairs(servers) do
    vim.lsp.config(server, config)
  end

  -- enable all known servers
  vim.lsp.enable(require 'mason-lspconfig'.get_installed_servers())
  vim.lsp.enable(vim.tbl_keys(servers))

  -- diagnostics are global
  vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

  local diagnostics = {
    signs = false,
    underline = true,
    update_in_insert = true,
  }

  local function virtual_line_enable(visible)
    if visible then
      diagnostics.virtual_lines = { current_line = true }
    else
      diagnostics.virtual_lines = false
    end
    vim.diagnostic.config(diagnostics)
  end

  virtual_line_enable(true)

  local visible = true
  vim.api.nvim_create_user_command('LspVirtualLineToggle', function()
    visible = not visible
    virtual_line_enable(visible)
  end, {})

  vim.api.nvim_create_autocmd('InsertEnter', {
    pattern = '*',
    callback = function()
      virtual_line_enable(false)
    end
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
      virtual_line_enable(visible)
    end
  })

  vim.keymap.set({ 'n', 'x' }, 'cf', function()
    print('no lsp, please format with gg=G')
  end, {})

  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = { buffer = event.buf }

      -- because they only work if you have an active language server
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)

      vim.keymap.set({ 'n', 'x' }, 'cf', function()
        print('formatted')
        vim.lsp.buf.format({ async = true })
      end, opts)
    end
  })
end)


-- dap
local function load_dap()
  load_once('dap', function()
    load_mason()
    vim.cmd.packadd 'nvim-dap'
    vim.cmd.packadd 'mason-nvim-dap.nvim'
    vim.cmd.packadd 'nvim-dap-view'
    vim.cmd.packadd 'nvim-dap-virtual-text'

    require 'mason-nvim-dap'.setup {
      handlers = {
        function(config)
          require 'mason-nvim-dap'.default_setup(config)
        end
      }
    }

    require 'dap-view'.setup {
      auto_toggle = true,
      winbar = {
        sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl', 'console' },
        controls = { enabled = true },
      }
    }

    require 'nvim-dap-virtual-text'.setup {}
  end)
end

vim.keymap.set('n', '<leader>dB', function()
  load_dap()
  require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Breakpoint Condition' })

vim.keymap.set('n', '<leader>db', function()
  load_dap()
  require 'dap'.toggle_breakpoint()
end, { desc = 'Toggle Breakpoint' })

vim.keymap.set('n', '<leader>dc', function()
  load_dap()
  require 'dap'.continue()
end, { desc = 'Run/Continue' })

vim.keymap.set('n', '<leader>da', function()
  load_dap()
  require 'dap'.continue()
end, { desc = 'Run with Args' })

vim.keymap.set('n', '<leader>dC', function()
  load_dap()
  require 'dap'.run_to_cursor()
end, { desc = 'Run to Cursor' })

vim.keymap.set('n', '<leader>dg', function()
  load_dap()
  require 'dap'.goto_()
end, { desc = 'Go to Line (No Execute)' })

vim.keymap.set('n', '<leader>di', function()
  load_dap()
  require 'dap'.step_into()
end, { desc = 'Step Into' })

vim.keymap.set('n', '<leader>dj', function()
  load_dap()
  require 'dap'.down()
end, { desc = 'Down' })

vim.keymap.set('n', '<leader>dk', function()
  load_dap()
  require 'dap'.up()
end, { desc = 'Up' })

vim.keymap.set('n', '<leader>dl', function()
  load_dap()
  require 'dap'.run_last()
end, { desc = 'Run Last' })

vim.keymap.set('n', '<leader>do', function()
  load_dap()
  require 'dap'.step_out()
end, { desc = 'Step Out' })

vim.keymap.set('n', '<leader>dO', function()
  load_dap()
  require 'dap'.step_over()
end, { desc = 'Step Over' })

vim.keymap.set('n', '<leader>dP', function()
  load_dap()
  require 'dap'.pause()
end, { desc = 'Pause' })

vim.keymap.set('n', '<leader>dr', function()
  load_dap()
  require 'dap'.repl.toggle()
end, { desc = 'Toggle REPL' })

vim.keymap.set('n', '<leader>ds', function()
  load_dap()
  require 'dap'.session()
end, { desc = 'Session' })

vim.keymap.set('n', '<leader>dt', function()
  load_dap()
  require 'dap'.terminate()
end, { desc = 'Terminate' })

vim.keymap.set('n', '<leader>dw', function()
  load_dap()
  require 'dap.ui.widgets'.hover()
end, { desc = 'Widgets' })


-- typst preview
lazy_cmd({ 'TypstPreview', 'TypstPreviewToggle' }, function()
  vim.cmd.packadd 'typst-preview.nvim'
  require 'typst-preview'.setup {
    dependencies_bin = {
      ['tinymist'] = vim.fn.exepath('tinymist'),
      ['websocat'] = vim.fn.exepath('websocat'),
    }
  }
end)


-- misc
lazy_cmd({ 'Outline', 'OutlineOpen' }, function()
  vim.cmd.packadd 'outline.nvim'
  require 'outline'.setup {}
end)

lazy(function()
  vim.cmd.packadd 'auto-save.nvim'
  require 'auto-save'.setup {}

  vim.cmd.packadd 'vim-visual-multi'

  vim.cmd.packadd 'smear-cursor.nvim'
  require 'smear_cursor'.setup {}

  vim.cmd.packadd 'auto-cursorline.nvim'
  require 'auto-cursorline'.setup {
    wait_ms = 100,
  }

  vim.cmd.packadd 'nvim-highlight-colors'
  require 'nvim-highlight-colors'.setup {
    render = 'virtual',
  }

  vim.cmd.packadd 'numb.nvim'
  require 'numb'.setup {}

  vim.cmd.packadd 'gitsigns.nvim'
  require 'gitsigns'.setup {
    signcolumn = true,
    attach_to_untracked = true,
    current_line_blame = false,
  }
end)

local function new_project_file()
  local nvim_lua = {
    'local success, dap = pcall(require, \'dap\')',
    'if success then',
    '  dap.configurations.c = {',
    '    {',
    '      name = \'Launch Linux\',',
    '      type = \'codelldb\',',
    '      request = \'launch\',',
    '      program = \'${workspaceFolder}/main\',',
    '      stopOnEntry = false,',
    '    },',
    '  }',
    'end',
  }

  vim.fn.writefile(nvim_lua, '.nvim.lua')
end

vim.api.nvim_create_user_command('NewProjectConfig', new_project_file, {})
