local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup()
    end,
    event = {
      'InsertLeave',
      'TextChanged'
    }
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
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
  }
  use {
    'catppuccin/nvim',
    as = 'catppuccin',
    config = function ()
      require('catppuccin').setup({
        no_italic = true
      })
      vim.cmd.colorscheme 'catppuccin'
    end
  }
  use {
    'phaazon/hop.nvim',
    config = function()
      require('hop').setup()
    end,
    cmd = 'HopWord'
  }
  use {
    'romgrk/barbar.nvim',
    requires = 'nvim-web-devicons'
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim',
    cmd = 'Telescope'
  }
  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim'
  }
  use {
    'akinsho/git-conflict.nvim',
    config = function()
      require('git-conflict').setup()
    end
  }
  use {
    'nvim-tree/nvim-tree.lua',
    requires = 'nvim-web-devicons',
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require('nvim-tree').setup()
    end,
    cmd = 'NvimTreeToggle'
  }
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup()
    end,
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'nvim-tree/nvim-web-devicons',
      opt = true
    },
    config = function()
      require('lualine').setup()
    end,
  }
  use 'nvim-tree/nvim-web-devicons'
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }
  use {
    'yamatsum/nvim-cursorline',
    config = function()
      require('nvim-cursorline').setup({
        cursorline = {
          enable = true,
          timeout = 200,
          number = true
        },
        cursorword = {
          enable = true,
          min_length = 1,
          hl = { underline = true },
        }
      })
    end
  }
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*';
        css = {
          css = true,
          RRGGBBAA = true
        };
      })
    end
  }

  use 'neovim/nvim-lspconfig'
  use {
    'williamboman/mason.nvim',
    run = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end
  }
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'FelipeLema/cmp-async-path',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      'kdheepak/cmp-latex-symbols'
    },
    config = function()
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
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
            compare.score,
            compare.recently_used,
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          }
        },
        mapping = {
          ['<Down>'] = map(map.select_next_item(), {'i', 's'}),
          ['<Up>'] = map(map.select_prev_item(), {'i', 's'}),
          ["<Tab>"] = cmp.mapping(function(fallback)
            -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              else
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {"i","s","c",}),
          ["<CR>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          })
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'snippy' },
          { name = "latex_symbols" },
          { name = 'nvim_lsp_signature_help' }
        },
          {
            { name = 'buffer' }
          })
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'async_path' }
        }, {
            { name = 'cmdline' }
          })
      })
    end
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      --'ms-jpq/coq_nvim'
      'hrsh7th/nvim-cmp'
    },
    config = function()
      require('mason-lspconfig').setup({
        automatic_installation = {
          exclude = {
            'clangd',
            'rust_analyzer',
            'lua_ls'
          }
        }
      })
      local lsp = require('lspconfig')
      --[[
local coq = require('coq')
local function ensure(setup)
  return coq.lsp_ensure_capabilities(setup)
  end
  --]]
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function setup(server)
        lsp[server].setup({
          capabilities = capabilities
        })
      end
      setup('pyright')
      setup('pylsp')
      setup('jdtls')
      setup('html')
      setup('clangd')
      setup('cssls')
      setup('lua_ls')
      setup('tsserver')
      setup('ltex')
      setup('rust_analyzer')

      --[[
  lsp.pyright.setup({})
  lsp.pylsp.setup({})
  lsp.jdtls.setup({})
  lsp.html.setup({})
  lsp.clangd.setup({})
  lsp.cssls.setup({})
  lsp.lua_ls.setup({})
  lsp.tsserver.setup({})
  lsp.ltex.setup({})
  lsp.rust_analyzer.setup({})
  --]]

      --[[
  lsp.pyright.setup(ensure({}))
  lsp.pylsp.setup(ensure({}))
  lsp.jdtls.setup(ensure({}))
  lsp.html.setup(ensure({}))
  lsp.clangd.setup(ensure({}))
  lsp.cssls.setup(ensure({}))
  lsp.lua_ls.setup(ensure({}))
  lsp.tsserver.setup(ensure({}))
  lsp.ltex.setup(ensure({}))
  lsp.rust_analyzer.setup(ensure({}))
  --]]
    end,
  }
  --[[use {
  'ms-jpq/coq_nvim',
  branch = 'coq',
  run = ':COQdeps',
  config = function()
  vim.g.coq_settings = {
  auto_start = 'shut-up'
  }
  end
  }
  use {
  'ms-jpq/coq.artifacts',
  branch = 'artifacts'
  }
  use {
  'ms-jpq/coq.thirdparty',
  branch = '3p'
  }
  --]]

  if packer_bootstrap then
    require('packer').sync()
  end
end)
