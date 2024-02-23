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

-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv("PREFIX") or "nil",
  "termux"
)

local usrDir = os.getenv("HOME") or os.getenv("USERPROFILE")

local haveWakaTime = false
wakaConfig = io.open(usrDir .. "/.wakatime.cfg")
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
    build = ':TSUpdate',
    config = function ()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
        indent = {
          enable = true
        }
      })
    end,
    event = 'VeryLazy'
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function ()
      require('catppuccin').setup({
        transparent_background = true,
        term_colors = true,
        no_italic = true
      })
      vim.cmd.colorscheme('catppuccin')
    end,
    build = ':CatppuccinCompile',
  },
  {
    'ggandor/leap.nvim',
    keys = '<M-/>',
    config = function ()
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
          function (win) return vim.api.nvim_win_get_config(win).focusable end,
          vim.api.nvim_tabpage_list_wins(0)
        )
        require('leap').leap { target_windows = focusable_windows_on_tabpage }
      end

      vim.keymap.set('', '<M-/>', leap)
      vim.keymap.set('i', '<M-/>', leap)
    end
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-web-devicons',
      'catppuccin'
    },
    event = 'VeryLazy'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'Telescope',
    init = function()
      vim.api.nvim_set_keymap('n', 'tt', ':Telescope<CR>', {})
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
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-web-devicons',
    config = function()
      require('nvim-tree').setup()
    end,
    cmd = 'NvimTreeToggle',
    init = function()
      vim.api.nvim_set_keymap('n', 'ff', ':NvimTreeToggle<CR>', {})
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
        '*';
        css = {
          css = true,
          RRGGBBAA = true
        };
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
      'hrsh7th/cmp-calc',
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
      local map = cmp.mapping
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
          ['<UP>'] = map(map.select_prev_item(), {'i', 's', 'c'}),
          ['<Down>'] = map(map.select_next_item(), {'i', 's', 'c'}),
          ['<M-Enter>'] = map(map.abort(), {'i', 's', 'c'}),
          ["<Enter>"] = map(function(fallback)
            -- enter selected completion
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if entry then
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {'i','s','c'}),
        },
        sources = cmp.config.sources({
          { name = 'calc' },
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
        mapping = map.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
    },
    build = ':MasonUpdate',
    init = function()
      require('mason').setup()

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

      require('mason-lspconfig').setup({
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
      require('mason-lspconfig').setup_handlers({
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
      vim.keymap.set('i', '<M-Right>', function() return vim.fn['codeium#Accept']() end, { expr = true })
      vim.keymap.set('i', '<M-Down>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      vim.keymap.set('i', '<M-Up>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
    end
  },
  {
    'wakatime/vim-wakatime',
    enabled = haveWakaTime,
    lazy = false
  }
})
