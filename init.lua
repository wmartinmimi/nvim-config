-- check if termux, need special workarounds
local isTermux = string.find(
  os.getenv('PREFIX') or 'nil',
  'termux'
)

-- alias --
local vim = vim
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set

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
-- dangerous, local project execution
opt.exrc = true
opt.secure = true


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
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function new_project_file()
  local nvim_lua = {
    "local success, dap = pcall(require, 'dap')",
    "if success then",
    "  dap.configurations.c = {",
    "    {",
    "      name = 'Launch Linux',",
    "      type = 'codelldb',",
    "      request = 'launch',",
    "      program = '${workspaceFolder}/main',",
    "      stopOnEntry = false,",
    "    },",
    "  }",
    "end",
  }

  vim.fn.writefile(nvim_lua, ".nvim.lua")
end

vim.api.nvim_create_user_command("NewNvimLua", new_project_file, {})

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
    build = ':TSUpdate',
    cmd = { 'TSInstall', 'TSInstallFromGrammar', 'TSUpdate', 'TSUninstall', 'TSLog' },
    init = function()
      local function load_treesitter(args)
        local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
        if ok then
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
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      -- disable presets to avoid conflict
      vim.g.no_plugin_maps = true
    end,
    opts = {}
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   branch = 'master',
  --   dependencies = {
  --     'HiPhish/rainbow-delimiters.nvim',
  --     { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
  --   },
  --   build = ':TSUpdate',
  --   config = function()
  --     require('nvim-treesitter.configs').setup({
  --       auto_install = true,
  --       highlight = {
  --         enable = true,
  --         additional_vim_regex_highlighting = false
  --       },
  --       autopairs = {
  --         enable = true
  --       },
  --       indent = {
  --         enable = true
  --       },
  --       rainbow = {
  --         enable = true,
  --       },
  --       incremental_selection = {
  --         enable = true,
  --         keymaps = {
  --           init_selection = "<C-space>",
  --           node_incremental = "<C-space>",
  --           scope_incremental = false,
  --           node_decremental = "<bs>",
  --         },
  --       },
  --       textobjects = {
  --         select = {
  --           enable = true,
  --           keymaps = {
  --             ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
  --             ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
  --             ["ap"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
  --             ["ip"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
  --             ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
  --             ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
  --             ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
  --             ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
  --             ["af"] = { query = "@function.outer", desc = "Select outer part of a function definition" },
  --             ["if"] = { query = "@function.inner", desc = "Select inner part of a function definition" },
  --             ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
  --             ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
  --           },
  --         },
  --         move = {
  --           enable = true,
  --           set_jumps = true, -- whether to set jumps in the jumplist
  --           goto_next_start = {
  --             ["]f"] = { query = "@function.outer", desc = "Next function def start" },
  --             ["]c"] = { query = "@class.outer", desc = "Next class start" },
  --             ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
  --             ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
  --             ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
  --           },
  --           goto_next_end = {
  --             ["]F"] = { query = "@function.outer", desc = "Next function def end" },
  --             ["]C"] = { query = "@class.outer", desc = "Next class end" },
  --             ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
  --             ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
  --           },
  --           goto_previous_start = {
  --             ["[f"] = { query = "@function.outer", desc = "Prev function def start" },
  --             ["[c"] = { query = "@class.outer", desc = "Prev class start" },
  --             ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
  --             ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
  --             ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
  --           },
  --           goto_previous_end = {
  --             ["[F"] = { query = "@function.outer", desc = "Prev function def end" },
  --             ["[C"] = { query = "@class.outer", desc = "Prev class end" },
  --             ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
  --             ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
  --           },
  --         },
  --       },
  --     })
  --
  --     opt.foldmethod = 'expr'
  --     opt.foldexpr = 'nvim_treesitter#foldexpr()'
  --     opt.foldlevel = 99 -- disable auto folding
  --   end,
  --   event = { 'BufReadPost', 'BufNewFile', 'BufWritePre', 'VeryLazy' },
  -- },
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
            ["@comment.error"] = { fg = colors.red, bg = "NONE", style = { "bold" } },
            ["@comment.warning"] = { fg = colors.yellow, bg = "NONE", style = { "bold" } },
            ["@comment.hint"] = { fg = colors.blue, bg = "NONE", style = { "bold" } },
            ["@comment.todo"] = { fg = colors.flamingo, bg = "NONE", style = { "bold" } },
            ["@comment.note"] = { fg = colors.rosewater, bg = "NONE", style = { "bold" } },
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
    'wmartinmimi/todo-highlight.nvim',
    opts = {
      -- TODO: add lua highlight function
      ts_query = function(ft)
        if ft == "typst" then
          return [[
            ((comment) @comment)
            ((text) @text)
          ]]
        end
        return [[(comment) @comment]]
      end,
      contextless = function(ft)
        return ft == "markdown"
      end,
    },
  },
  {
    'sphamba/smear-cursor.nvim',
    commit = 'c85bdbb',
    event = 'VeryLazy',
    opts = {},
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
      { 'tt', '<CMD>Telescope<CR>', desc = 'opens telescope' },
      {
        '<leader>lf',
        function() require('telescope.builtin').lsp_document_symbols({ symbols = 'function' }) end,
        desc = 'list functions in file'
      },
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
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      }
    }
  },
  {
    'https://gitlab.com/HiPhish/rainbow-delimiters.nvim',
    commit = 'd6b802552cbe7d643a3b6b31f419c248d1f1e220',
    submodules = false,
    event = 'User TSBufAttach',
    config = function()
      require('rainbow-delimiters').enable()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSBufAttach',
        callback = function()
          require('rainbow-delimiters').enable()
        end,
      })
    end
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
    'brenoprata10/nvim-highlight-colors',
    commit = 'b42a5cc',
    opts = {
      render = 'virtual',
    },
    event = 'VeryLazy',
  },
  {
    'hedyhli/outline.nvim',
    commit = '1967ef5',
    cmd = { 'Outline', 'OutlineOpen' },
    opts = {},
  },
  {
    'nacro90/numb.nvim',
    commit = '8164fd3',
    event = { 'VeryLazy' },
    opts = {},
  },
  {
    'saghen/blink.cmp',
    dependencies = {
      { 'moyiz/blink-emoji.nvim',           commit = '066013e' },
      { 'MahanRahmati/blink-nerdfont.nvim', commit = 'e503445', },
      { 'erooke/blink-cmp-latex',           commit = '3a95836' },
      { 'ribru17/blink-cmp-spell',          commit = '2bd0e0d' },
    },
    version = '1.*',
    init = function()
      vim.opt.spell = true
      vim.opt.spelllang = { 'en_gb', 'en_us' }
      -- TODO: better location to place this
      vim.api.nvim_set_hl(0, 'SnippetTabstop', {})
      vim.api.nvim_set_hl(0, 'SnippetTabstopActive', {})
    end,
    opts = {
      cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = { auto_show = true } },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        ghost_text = { enabled = true },
        menu = {
          -- TODO: menu item direction, not implemented yet
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
              return vim.opt.spell:get()
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
        ['<M-Right>'] = { 'accept' },
      },
    },
    event = {
      'InsertEnter',
      'CmdlineEnter'
    },
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
        ['tinymist'] = vim.fn.exepath('tinymist'),
        ['websocat'] = vim.fn.exepath('websocat'),
      }
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
    opts = {},
    event = { 'VeryLazy' },
    config = function()
      -- apply user configuration
      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
      end

      -- enable all known servers
      vim.lsp.enable(require('mason-lspconfig').get_installed_servers())
      vim.lsp.enable(vim.tbl_keys(servers))

      -- diagnostics are global
      map('n', 'gl', vim.diagnostic.open_float)

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

      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        callback = function()
          virtual_line_enable(false)
        end
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        callback = function()
          virtual_line_enable(visible)
        end
      })

      map({ 'n', 'x' }, 'cf', function()
        print('no lsp, please format with gg=G')
      end, {})

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }

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
    'mfussenegger/nvim-dap',
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'igorlfs/nvim-dap-view',
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
    end,
    lazy = true,
  },
  {
    'igorlfs/nvim-dap-view',
    opts = {
      auto_toggle = true,
      winbar = {
        sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
        controls = { enabled = true },
      }
    },
    lazy = true,
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    commit = 'fbdb48c',
    opts = {},
    keys = {
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        desc = "Breakpoint Condition"
      },
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint"
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "Run/Continue"
      },
      {
        "<leader>da",
        function() require("dap").continue() end,
        desc = "Run with Args"
      },
      {
        "<leader>dC",
        function() require("dap").run_to_cursor() end,
        desc = "Run to Cursor"
      },
      {
        "<leader>dg",
        function() require("dap").goto_() end,
        desc = "Go to Line (No Execute)"
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "Step Into"
      },
      {
        "<leader>dj",
        function() require("dap").down() end,
        desc = "Down"
      },
      {
        "<leader>dk",
        function() require("dap").up() end,
        desc = "Up"
      },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc = "Run Last"
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc = "Step Out"
      },
      {
        "<leader>dO",
        function() require("dap").step_over() end,
        desc = "Step Over"
      },
      {
        "<leader>dP",
        function() require("dap").pause() end,
        desc = "Pause"
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc = "Toggle REPL"
      },
      {
        "<leader>ds",
        function() require("dap").session() end,
        desc = "Session"
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc = "Terminate"
      },
      {
        "<leader>dw",
        function() require("dap.ui.widgets").hover() end,
        desc = "Widgets"
      },
    },
  },
}

require('lazy').setup(config)
