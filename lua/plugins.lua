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

require('lazy').setup({
  'folke/lazy.nvim',
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup()
    end,
    event = 'VeryLazy'
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
    config = function ()
      require('catppuccin').setup({
        term_colors = true,
        no_italic = true
      })
      vim.cmd.colorscheme('catppuccin')
    end,
    build = ':CatppuccinCompile',
  },
  {
    'phaazon/hop.nvim',
    config = function()
      require('hop').setup()
    end,
    cmd = 'HopWord'
  },
  {
    'romgrk/barbar.nvim',
    dependencies = 'nvim-web-devicons',
    event = 'VeryLazy'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'Telescope'
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
    cmd = 'NvimTreeToggle'
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup()
    end,
    event = 'VeryLazy'
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
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
      'lukas-reineke/cmp-rg',
      'FelipeLema/cmp-async-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      'kdheepak/cmp-latex-symbols',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-calc',
      'f3fora/cmp-spell'
    },
    event = {
      'InsertEnter',
      'CmdlineEnter'
    },
    config = function()

      -- required by spell
      vim.opt.spell = true
      vim.opt.spelllang = { 'en_uk', 'en_us' }


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
          ['<Down>'] = map(map.select_next_item(), {'i', 's', 'c'}),
          ['<Up>'] = map(map.select_prev_item(), {'i', 's', 'c'}),
          ["<Tab>"] = map(function(fallback)
            -- enter selected completion
            -- enter 1st completion if none selected
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({
                  behavior = cmp.SelectBehavior.Select
                })
              else
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {'i','s','c'}),
          ["<CR>"] = map({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = false
                })
              else
                fallback()
              end
            end,
            s = map.confirm({
              select = true
            }),
            c = map.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true
            }),
          })
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
            { name = 'rg' }
          })
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = map.preset.cmdline(),
        sources = {
          { name = 'rg' }
        }
      })
      cmp.setup.cmdline(':', {
        mapping = map.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'async_path' }
        }, {
            { name = 'cmdline' }
          })
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
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        automatic_installation = {
          exclude = {
            'clangd',
            'rust_analyzer',
            'lua_ls',
            'texlab'
          }
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
      -- lsp that is installed outside mason
      setup('clangd')
      setup('rust_analyzer')
      setup('lua_ls')
      setup('texlab')
    end
  }
})
