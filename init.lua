-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv('PREFIX') or 'nil',
  'termux'
)

-- set ai autocomplete
local ai_cmp = not isTermux

-- alias --
local vim = vim
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set

-- LSP --
local servers = {
  {
    'tinymist', -- mem leak
    settings = {
      exportPdf = 'onSave',
      formatterMode = 'typstyle',
    },
  },
  -- python autocomplete as ruff does not do that
  {
    'pylsp',
    settings = {
      pylsp = {
        plugins = {
          -- linting provided by ruff
          ruff = { enabled = true },
        }
      }
    }
  },
}

-- options --
opt.encoding = 'utf8'
opt.fileformat = 'unix'
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.expandtab = true
opt.lazyredraw = true
opt.linebreak = true
opt.scrolloff = 999

if isTermux then
  opt.tabstop = 2
  opt.shiftwidth = 2
else
  opt.tabstop = 4
  opt.shiftwidth = 4
end

g.do_filetype_lua = true
g.did_load_filetypes = false

-- quicker loader
vim.loader.enable()

-- bootstrapping
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugin configs
local config = {
  'folke/lazy.nvim',
  {
    'Pocco81/auto-save.nvim',
    commit = '979b6c8',
    opts = {},
    event = 'VeryLazy',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'HiPhish/rainbow-delimiters.nvim',
      'nvim-treesitter/nvim-treesitter-textobjects',
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
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
              ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
              ["ap"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
              ["ip"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
              ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
              ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
              ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
              ["af"] = { query = "@function.outer", desc = "Select outer part of a function definition" },
              ["if"] = { query = "@function.inner", desc = "Select inner part of a function definition" },
              ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function def start" },
              ["]c"] = { query = "@class.outer", desc = "Next class start" },
              ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
              ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function def end" },
              ["]C"] = { query = "@class.outer", desc = "Next class end" },
              ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
              ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev function def start" },
              ["[c"] = { query = "@class.outer", desc = "Prev class start" },
              ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
              ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
              ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Prev function def end" },
              ["[C"] = { query = "@class.outer", desc = "Prev class end" },
              ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
              ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
            },
          },
        },
      })

      opt.foldmethod = 'expr'
      opt.foldexpr = 'nvim_treesitter#foldexpr()'
      opt.foldlevel = 99 -- disable auto folding
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
    commit = '84a4987',
    opts = {},
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    "folke/flash.nvim",
    commit = '3c94266',
    opts = {
      modes = {
        treesitter = {
          highlight = {
            backdrop = true,
          },
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash"
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter"
      },
      {
        "r",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash"
      },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search"
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search"
      },
    },
  },
  {
    'mg979/vim-visual-multi',
    commit = 'a6975e7',
    branch = 'master',
    event = 'VeryLazy',
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-web-devicons',
      'catppuccin'
    },
    commit = '3a74402',
    event = 'UIEnter',
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
      local trouble = require('trouble.sources.telescope')

      local telescope = require('telescope')

      telescope.setup {
        defaults = {
          mappings = {
            i = { ['<c-t>'] = trouble.open },
            n = { ['<c-t>'] = trouble.open },
          },
        },
      }
    end
  },
  {
    'kevinhwang91/nvim-fundo',
    commit = 'ac9c937',
    run = function()
      require('fundo').install()
    end,
    init = function()
      opt.undofile = true
    end
  },
  {
    'mbbill/undotree',
    commit = '15d91b0',
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
    commit = 'b0b4955',
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
    commit = '005b560',
    main = 'ibl',
    event = 'VeryLazy',
    opts = {}
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    commit = '55ad4fb',
    event = { 'BufReadPost', 'BufNewFile' },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'catppuccin'
    },
    commit = 'a94fc68',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },
  {
    'windwp/nvim-autopairs',
    opts = {
      check_ts = true,
    },
    event = 'InsertEnter',
  },
  {
    'delphinus/auto-cursorline.nvim',
    commit = 'ad7e0d4',
    event = 'VeryLazy',
    opts = {
      wait_ms = 100,
    },
  },
  {
    'tzachar/local-highlight.nvim',
    commit = '272f36f',
    opts = {
      hlgroup = "@text.underline",
      cw_hlgroup = "@text.underline",
      insert_mode = true,
      debounce_timeout = 100,
      animate = false,
    },
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
    event = 'VeryLazy'
  },
  {
    'brenoprata10/nvim-highlight-colors',
    commit = 'b42a5cc',
    opts = {
      render = 'virtual',
    },
    event = 'VeryLazy',
  },
  {
    'iguanacucumber/magazine.nvim',
    name = 'nvim-cmp',
    dependencies = {
      'dcampos/nvim-snippy',
      'cmp-nvim-lsp',
      { 'iguanacucumber/mag-buffer',  name = 'cmp-buffer' },
      'https://codeberg.org/FelipeLema/cmp-async-path',
      { 'iguanacucumber/mag-cmdline', name = 'cmp-cmdline' },
      'onsails/lspkind.nvim',
      'kdheepak/cmp-latex-symbols',
      'hrsh7th/cmp-emoji',
      'chrisgrieser/cmp-nerdfont',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      'f3fora/cmp-spell',
      'brenoprata10/nvim-highlight-colors',
      'Exafunction/windsurf.nvim',
    },
    event = {
      'InsertEnter',
      'CmdlineEnter'
    },
    config = function()
      -- required by spell
      vim.opt.spell = true
      vim.opt.spelllang = { 'en_gb', 'en_us' }


      local cmp = require('cmp')
      local cmp_map = cmp.mapping
      local compare = require('cmp.config.compare')

      cmp.setup({
        experimental = {
          ghost_text = true,
        },
        view = {
          entries = {
            name = 'custom',
            vertical_positioning = 'above',
            selection_order = 'bottom_up',
          }
        },
        formatting = {
          format = function(entry, item)
            local lspkind_item = require('lspkind').cmp_format({
              ellipsis_char = '..',
              symbol_map = {
                Codeium = '',
              }
            })(entry, item)
            local color_item = require('nvim-highlight-colors').format(entry, { kind = item.kind })
            item = lspkind_item
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
          ['<Down>'] = cmp_map(function(fallback)
            if cmp.visible() then
              if cmp.core.view.custom_entries_view:is_direction_top_down() then
                cmp.select_next_item()
              else
                cmp.select_prev_item()
              end
            else
              fallback()
            end
          end, { 'i', 's', 'c' }),
          ['<Up>'] = cmp_map(function(fallback)
            if cmp.visible() then
              if cmp.core.view.custom_entries_view:is_direction_top_down() then
                cmp.select_prev_item()
              else
                cmp.select_next_item()
              end
            else
              fallback()
            end
          end, { 'i', 's', 'c' }),
          ['<M-Left>'] = cmp_map(cmp_map.abort(), { 'i', 's', 'c' }),
          ['<M-Right>'] = cmp_map(function(fallback)
            -- enter selected completion
            if cmp.visible() then
              cmp.confirm({ select = true })
            end
            fallback()
          end, { 'i', 's', 'c' }),
          ['<C-j>'] = cmp_map(cmp_map.scroll_docs(1), { 'i', 's', 'c' }),
          ['<C-k>'] = cmp_map(cmp_map.scroll_docs(-1), { 'i', 's', 'c' }),
        },
        sources = {
          { name = 'codeium',       priority = 1100 },
          { name = 'nvim_lsp',      priority = 1000 },
          { name = 'snippy',        priority = 1000 },
          { name = 'async_path',    priority = 600 },
          { name = 'latex_symbols', priority = 400 },
          { name = 'nerdfont',      priority = 400 },
          { name = 'emoji',         priority = 400 },
          {
            name = 'spell',
            option = {
              keep_all_entries = true,
              enable_in_context = function()
                return require('cmp.config.context').in_treesitter_capture('spell')
              end
            },
            priority = 200,
          },
        }
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
    'folke/trouble.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    commit = '85bedb7',
    opts = {},
    keys = {
      { 'cd', function() require('trouble').toggle({ mode = 'diagnostics' }) end, desc = 'opens trouble' },
    },
  },
  {
    'stevearc/quicker.nvim',
    commit = '51d3926',
    event = "FileType qf",
    opts = {},
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signcolumn = true,
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text_pos = 'right_align',
        virt_text_priority = 1000,
        delay = 50,
      },
    },
  },
  {
    'chomosuke/typst-preview.nvim',
    commit = 'dea4525',
    cmd = {
      'TypstPreview',
      'TypstPreviewToggle',
    },
    opts = {
      dependencies_bin = {
        ['tinymist'] = 'tinymist',
        ['websocat'] = 'websocat',
      }
    },
  },
  {
    'williamboman/mason.nvim',
    lazy = true,
    opts = {},
    build = ':MasonUpdate',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      { 'iguanacucumber/mag-nvim-lsp', name = 'cmp-nvim-lsp' },
      'neovim/nvim-lspconfig',
    },
    event = { 'BufReadPost', 'BufNewFile', 'VeryLazy' },
    config = function()
      -- setting up dependencies
      require('mason-lspconfig').setup()

      -- setup capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- default handler to process lsp servers
      local default_config = function(server)
        local config = {}
        if type(server) == 'table' then
          config = server
          server = server[1]
        end
        if config.capabilities == nil then
          config.capabilities = capabilities
        end
        return { name = server, config = config }
      end

      local lsp_configs = {}

      -- process servers installed from mason
      local mason_servers = require('mason-lspconfig').get_installed_servers()
      for _, server in pairs(mason_servers) do
        local config = default_config(server)
        lsp_configs[config.name] = config.config
      end

      -- process user server configurations
      for _, server in pairs(servers) do
        local config = default_config(server)
        lsp_configs[config.name] = config.config
      end

      -- setup servers
      for server, config in pairs(lsp_configs) do
        vim.lsp.enable(server, config)
      end

      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      map('n', 'gl', vim.diagnostic.open_float)

      local function virtual_line_enable(visible)
        local vl_config
        if visible then
          vl_config = { current_line = true }
        else
          vl_config = false
        end
        vim.diagnostic.config({
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = '',
              [vim.diagnostic.severity.WARN] = '',
            },
          },
          virtual_lines = vl_config,
          underline = true,
        })
      end

      local visible = true
      virtual_line_enable(visible)
      vim.api.nvim_create_user_command('ToggleVirtualLine', function()
        visible = not visible
        virtual_line_enable(visible)
      end, {})

      map({ 'n', 'x' }, 'cf', function()
        print('no lsp, please format with gg=G')
      end, {})

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }

          -- these will be buffer-local keybindings
          -- because they only work if you have an active language server

          map('n', 'gd', vim.lsp.buf.definition, opts)
          map('n', 'gD', vim.lsp.buf.declaration, opts)
          map('n', 'go', vim.lsp.buf.type_definition, opts)
          map('n', 'gs', vim.lsp.buf.signature_help, opts)
          map({ 'n', 'x' }, 'cf', function()
            print('formatted')
            vim.lsp.buf.format({ async = true })
          end, opts)
        end
      })
    end,
  },
  {
    'Exafunction/windsurf.nvim',
    event = 'InsertEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-cmp',
    },
    cmd = 'Codeium',
    enabled = ai_cmp,
    config = function()
      require('codeium').setup()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'rcarriga/nvim-dap-ui',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      -- mason integration
      require('mason-nvim-dap').setup {
        handlers = {
          function(config) -- default configuration
            require('mason-nvim-dap').default_setup(config)
          end
        }
      }

      -- ui for debugging
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
    lazy = true,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'nvim-neotest/nvim-nio',
    },
    commit = '73a26ab',
    opts = {},
    lazy = true,
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    commit = 'fbdb48c',
    opts = {},
    cmd = {
      'DapContinue',
      'DapNew',
      'DapToggleBreakpoint',
      'DapInstall',
      'DapUninstall',
      'DapToggleRepl',
    },
  },
}

require('lazy').setup(config)
