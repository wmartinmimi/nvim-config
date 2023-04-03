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

  use 'neovim/nvim-lspconfig'
  use {
    'williamboman/mason.nvim',
    run = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim'
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
    end,
  }
  use {
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

  if packer_bootstrap then
    require('packer').sync()
  end
end)
