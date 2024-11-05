-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv("PREFIX") or "nil",
  "termux"
)

-- alias --
local vim = vim
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set

-- LSP --
local servers = {
  'lua_ls',
  'clangd',
  'superhtml',
  'astro',
  'ts_ls',
  'html',
  'cssls',
  'bashls',
  'cmake',
  'gopls',
  'typst_lsp',
  'zls',
  'pylsp',
}

-- workarounds --
g.zig_fmt_autosave = false -- required until nvim v0.11.0

-- options --
opt.encoding = 'utf8'
opt.fileformat = 'unix'
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.expandtab = true
opt.lazyredraw = true
opt.linebreak = true

if isTermux then
  opt.tabstop = 2
  opt.shiftwidth = 2
else
  opt.tabstop = 4
  opt.shiftwidth = 4
end

g.do_filetype_lua = true
g.did_load_filetypes = false

-- bootstrapping
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local usrDir = os.getenv("HOME") or os.getenv("USERPROFILE")

-- plugin configs
local config = {
  'folke/lazy.nvim',
  {
    'Pocco81/auto-save.nvim',
    opts = {},
    event = 'VeryLazy',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'HiPhish/rainbow-delimiters.nvim',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
        autopairs = {
          enable = true
        },
        indent = {
          enable = true
        },
        rainbow = {
          enable = true,
        }
      })
    end,
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre', 'VeryLazy' },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
      -- run :CatppuccinCompile after config change
      require('catppuccin').setup({
        transparent_background = not isTermux,
        term_colors = true,
        no_italic = true,
        custom_highlights = function(colors)
          return {
            LineNr = { fg = colors.overlay0 },
          }
        end
      })
      vim.cmd.colorscheme('catppuccin')
    end,
    build = ':CatppuccinCompile',
  },
  {
    'nmac427/guess-indent.nvim',
    opts = {},
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    'ggandor/leap.nvim',
    keys = {
      { '<M-/>', desc = 'run leap.nvim' },
    },
    config = function()
      local hl = vim.api.nvim_set_hl

      hl(0, 'LeapBackdrop', {
        link = 'Comment'
      })
      hl(0, 'LeapMatch', {
        fg = '#89b4fa',
        bold = true,
        nocombine = true
      })
      hl(0, 'LeapLabelPrimary', {
        fg = '#f38ba8',
        bold = true,
        nocombine = true
      })
      hl(0, 'LeapLabelSecondary', {
        fg = '#f9e2af',
        bold = true,
        nocombine = true
      })
      require('leap').opts.highlight_unlabeled_phase_one_targets = true

      local function leap()
        local focusable_windows_on_tabpage = vim.tbl_filter(
          function(win) return vim.api.nvim_win_get_config(win).focusable end,
          vim.api.nvim_tabpage_list_wins(0)
        )
        require('leap').leap { target_windows = focusable_windows_on_tabpage }
      end

      map('', '<M-/>', leap)
      map('i', '<M-/>', leap)
    end
  },
  {
    'mg979/vim-visual-multi',
    branch = 'master',
    event = 'VeryLazy',
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-web-devicons',
      'catppuccin'
    },
    event = 'UIEnter'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
    },
    keys = {
      { 'tt', '<CMD>Telescope<CR>', desc = 'opens telescope' }
    },
    cmd = 'Telescope',
    config = function()
      local trouble = require("trouble.sources.telescope")

      local telescope = require("telescope")

      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
          },
        },
      }
    end
  },
  {
    'kevinhwang91/nvim-fundo',
    run = function()
      require('fundo').install()
    end,
    init = function()
      opt.undofile = true
    end
  },
  {
    'mbbill/undotree',
    keys = {
      {
        'tu',
        '<cmd>UndotreeToggle<CR>',
        desc = 'toggle undo tree'
      }
    },
    config = function()
      g.undotree_ShortIndicators = true
      g.undotree_SetFocusWhenToggle = true
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-web-devicons',
    opts = {
      hijack_unnamed_buffer_when_opening = true,
    },
    cmd = 'NvimTreeToggle',
    keys = {
      { 'ff', '<CMD>NvimTreeToggle<CR>', desc = 'opens nvim-tree' }
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = {
      'nmac427/guess-indent.nvim',
    },
    main = "ibl",
    event = 'VeryLazy',
    opts = {}
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'catppuccin'
    },
    event = 'VeryLazy',
    opts = {},
  },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      check_ts = true,
    },
    event = 'InsertEnter',
  },
  {
    'delphinus/auto-cursorline.nvim',
    event = 'VeryLazy',
    opts = {
      wait_ms = 200,
    },
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
    event = 'VeryLazy'
  },
  {
    'brenoprata10/nvim-highlight-colors',
    opts = {
      render = 'virtual',
    },
    event = 'VeryLazy',
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'dcampos/nvim-snippy',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      'kdheepak/cmp-latex-symbols',
      'hrsh7th/cmp-emoji',
      'f3fora/cmp-spell',
      'brenoprata10/nvim-highlight-colors',
    },
    event = {
      'InsertEnter',
      'CmdlineEnter'
    },
    config = function()
      -- required by spell
      vim.opt.spell = true
      vim.opt.spelllang = { 'en_us' }


      local cmp = require('cmp')
      local cmp_map = cmp.mapping
      local compare = require('cmp.config.compare')

      cmp.setup({
        formatting = {
          format = function(entry, item)
            local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
            item = require("lspkind").cmp_format({ ellipsis_char = '..' })(entry, item)
            -- nvim-highlight-colors integration
            if color_item.abbr_hl_group then
              item.kind_hl_group = color_item.abbr_hl_group
              item.kind = color_item.abbr
            end
            return item
          end,
        },
        snippet = {
          expand = function(args)
            require('snippy').expand_snippet(args.body)
          end
        },
        matching = {
          disallow_fuzzying_matching = false,
          disallow_partial_fuzzying_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false
        },
        sorting = {
          priority_weight = 2.0,
          comparators = {
            compare.locality,
            compare.recently_used,
            compare.score,
            compare.offset
          }
        },
        mapping = {
          ['<UP>'] = cmp_map(cmp_map.select_prev_item(), { 'i', 's', 'c' }),
          ['<Down>'] = cmp_map(cmp_map.select_next_item(), { 'i', 's', 'c' }),
          ['<M-Enter>'] = cmp_map(cmp_map.abort(), { 'i', 's', 'c' }),
          ["<Enter>"] = cmp_map(function(fallback)
            -- enter selected completion
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if entry then
                cmp.confirm()
              else
                fallback()
              end
            else
              fallback()
            end
          end, { 'i', 's', 'c' }),
          ['<C-j>'] = cmp_map(cmp_map.scroll_docs(1), { 'i', 's', 'c' }),
          ['<C-k>'] = cmp_map(cmp_map.scroll_docs(-1), { 'i', 's', 'c' }),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'snippy' }
          },
          {
            { name = 'latex_symbols' },
            {
              name = 'emoji',
              option = {
                insert = true
              }
            },
            {
              name = 'spell',
              option = {
                keep_all_entries = true,
                enable_in_context = function()
                  return require('cmp.config.context').in_treesitter_capture('spell')
                end
              }
            },
            { name = 'buffer' }
          })
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp_map.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    event = { 'BufReadPost', 'BufNewFile', 'VeryLazy' },
    config = function()
      local lsp = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      for _, server in pairs(servers) do
        local config = {}
        if type(server) == "table" then
          config = server
          server = server[1]
        end
        if config.capabilities == nil then
          config.capabilities = capabilities
        end
        lsp[server].setup(config)
      end

      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      map('n', 'gl', vim.diagnostic.open_float)
      map('n', '[d', vim.diagnostic.goto_prev)
      map('n', ']d', vim.diagnostic.goto_next)

      local visible = true
      map('n', 'll', function()
        visible = not visible
        if visible then
          print('errors enabled: true')
        else
          print('errors enabled: false')
        end
        vim.diagnostic.config({
          virtual_text = visible,
          underline = visible,
        })
      end)

      map({ 'n', 'x' }, 'cf', function()
        print('no lsp, please format with gg=G')
      end, {})

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }

          -- these will be buffer-local keybindings
          -- because they only work if you have an active language server

          map('n', 'K', vim.lsp.buf.hover, opts)
          map('n', 'gd', vim.lsp.buf.definition, opts)
          map('n', 'gD', vim.lsp.buf.declaration, opts)
          map('n', 'gi', vim.lsp.buf.implementation, opts)
          map('n', 'go', vim.lsp.buf.type_definition, opts)
          map('n', 'gr', vim.lsp.buf.references, opts)
          map('n', 'gs', vim.lsp.buf.signature_help, opts)
          map('n', 'cr', vim.lsp.buf.rename, opts)
          map({ 'n', 'x' }, 'cf', function()
            print('formatted')
            vim.lsp.buf.format({ async = true })
          end, opts)
          map('n', 'ca', vim.lsp.buf.code_action, opts)
        end
      })

      vim.api.nvim_create_user_command('LspConfigDocs', function(_)
        local docs = vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig/doc/configs.md"
        vim.cmd('view ' .. docs)
        vim.cmd('setlocal nomodifiable')
      end, {})
    end
  },
  {
    'folke/trouble.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {},
    keys = {
      { 'cd', function() require('trouble').toggle({ mode = 'diagnostics' }) end, desc = 'opens trouble' },
    },
  },
  {
    'Exafunction/codeium.vim',
    event = 'InsertEnter',
    cmd = {
      'Codeium',
      'CodeiumEnable',
      'CodeiumAuto'
    },
    enabled = not isTermux,
    keys = {
      { '<M-Right>', function() return vim.fn['codeium#Accept']() end,             mode = 'i', expr = true },
      { '<M-Down>',  function() return vim.fn['codeium#CycleCompletions'](1) end,  mode = 'i', expr = true },
      { '<M-Up>',    function() return vim.fn['codeium#CycleCompletions'](-1) end, mode = 'i', expr = true },
    },
    config = function()
      vim.g.codeium_disable_bindings = 1
    end,
  },
  {
    'wakatime/vim-wakatime',
    enabled = function()
      local wakaConfig = io.open(usrDir .. "/.wakatime.cfg")
      if wakaConfig ~= nil then
        wakaConfig:close()
        return true
      end
      return false
    end,
    lazy = false
  },
}

require('lazy').setup(config)
