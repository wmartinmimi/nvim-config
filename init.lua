-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv("PREFIX") or "nil",
  "termux"
)

-- alias
local vim = vim
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set

-- options
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

local haveWakaTime = false
local wakaConfig = io.open(usrDir .. "/.wakatime.cfg")
if wakaConfig ~= nil then
  haveWakaTime = true
  wakaConfig:close()
end

require('lazy').setup({
  'folke/lazy.nvim',
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      vim.g.mkdp_theme = 'light'
      vim.g.mkdp_echo_preview_url = 1
    end,
  },
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup()
    end,
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
        no_italic = true
      })
      vim.cmd.colorscheme('catppuccin')
    end,
    build = ':CatppuccinCompile',
  },
  {
    'nmac427/guess-indent.nvim',
    opts = {}
  },
  {
    'ggandor/leap.nvim',
    keys = '<M-/>',
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
      'folke/trouble.nvim'
    },
    cmd = 'Telescope',
    init = function()
      map('n', 'tt', ':Telescope<CR>')
    end,
    config = function()
      local trouble = require("trouble.providers.telescope")

      local telescope = require("telescope")

      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          },
        },
      }
    end
  },
  {
    'kevinhwang91/nvim-fundo',
    run = function ()
      require('fundo').install()
    end,
    init = function ()
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
    config = function ()
      g.undotree_ShortIndicators = true
      g.undotree_SetFocusWhenToggle = true
    end
  },
  {
    'akinsho/git-conflict.nvim',
    config = function()
      require('git-conflict').setup()
    end,
    event = 'VeryLazy'
  },
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-web-devicons',
    config = function()
      require('nvim-tree').setup()
    end,
    cmd = 'NvimTreeToggle',
    init = function()
      map('n', 'ff', ':NvimTreeToggle<CR>')
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    event = 'VeryLazy',
    config = function()
      require('ibl').setup()
    end,
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'catppuccin'
    },
    config = function()
      require('lualine').setup()
    end,
    event = 'VeryLazy'
  },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
    event = 'InsertEnter'
  },
  {
    'delphinus/auto-cursorline.nvim',
    config = function()
      require('auto-cursorline').setup({
        wait_ms = 200
      })
    end,
    event = 'VeryLazy'
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
    event = 'VeryLazy'
  },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*',
        css = {
          css = true,
          RRGGBBAA = true
        },
      })
    end,
    event = 'VeryLazy'
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'FelipeLema/cmp-async-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      'kdheepak/cmp-latex-symbols',
      'hrsh7th/cmp-emoji',
      'f3fora/cmp-spell',
      'williamboman/mason-lspconfig.nvim'
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
          format = require('lspkind').cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            ellipsis_char = '...'
          })
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
    'williamboman/mason.nvim',
    lazy = false,
    opts = {}
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'hrsh7th/cmp-nvim-lsp'
    },
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':MasonUpdate',
    config = function()
      local exclude = {
        -- lsp you want to exclude
        -- example
        -- 'clangd',
      }

      if isTermux then
        exclude = {
          'clangd',
          'rust_analyzer',
          'lua_ls'
        }
      end

      local mason = require('mason-lspconfig')
      mason.setup({
        automatic_installation = {
          exclude = exclude
        }
      })

      local lsp = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function setup(server)
        lsp[server].setup({
          capabilities = capabilities
        })
      end
      mason.setup_handlers({
        setup
      })

      if isTermux then
        -- lsp installed outside mason
        -- example:
        --
        setup('clangd')
        setup('rust_analyzer')
        setup('lua_ls')
      end

      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      map('n', 'gl', vim.diagnostic.open_float)
      map('n', '[d', vim.diagnostic.goto_prev)
      map('n', ']d', vim.diagnostic.goto_next)

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
    end
  },
  {
    'folke/trouble.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    event = 'VeryLazy',
    opts = {},
    config = function ()
      local trouble = require('trouble')
      map('n', 'cd', trouble.toggle)
    end
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
    config = function()
      map('i', '<M-Right>', function() return vim.fn['codeium#Accept']() end, { expr = true })
      map('i', '<M-Down>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      map('i', '<M-Up>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
    end
  },
  {
    'wakatime/vim-wakatime',
    enabled = haveWakaTime,
    lazy = false
  }
})
