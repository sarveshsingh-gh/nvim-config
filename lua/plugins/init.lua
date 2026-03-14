-- User plugins loaded on top of NvChad's built-in plugin set.
-- NvChad already provides: mason, nvim-lspconfig, nvim-cmp, luasnip,
-- telescope, nvim-treesitter, gitsigns, which-key, autopairs, nvim-web-devicons.
-- We only add what NvChad does NOT include.

return {
  -- ── which-key: trigger on g / [ / ] in addition to <leader> ─────────────
  {
    "folke/which-key.nvim",
    opts = {
      delay = 300,
      win   = { border = "rounded" },
      spec = {
        -- ── General ──────────────────────────────────────────────────
        { "<leader>w", desc = "Save file" },
        { "<leader>q", desc = "Quit" },
        { "-",         desc = "Oil: open parent dir" },
        { "K",         desc = "LSP: Hover docs" },
        { "<C-Space>", desc = "LSP: Hover docs", mode = { "n", "v" } },

        -- ── F-keys (DAP one-press) ────────────────────────────────────
        { "<F5>",  desc = "DAP: Continue / Start" },
        { "<F8>",  desc = "DAP: Step out" },
        { "<F9>",  desc = "DAP: Toggle breakpoint" },
        { "<F10>", desc = "DAP: Step over" },
        { "<F11>", desc = "DAP: Step into" },
        { "<F12>", desc = "LSP: Go to implementation", mode = { "n", "v" } },
        { "<S-F5>",desc = "DAP: Stop / Terminate" },

        -- ── Goto (g) ─────────────────────────────────────────────────
        { "g",   group = "Goto", mode = { "n", "v" } },
        { "gd",        desc  = "Definition",              mode = { "n", "v" } },
        { "<leader>/", desc  = "Go to definition",       mode = { "n", "v" } },
        { "<leader>,", desc  = "Go to implementation",   mode = { "n", "v" } },
        { "gD",        desc  = "Declaration",            mode = { "n", "v" } },
        { "gy",  desc  = "Type definition",         mode = { "n", "v" } },
        { "gr",  desc  = "References (Telescope)",  mode = { "n", "v" } },
        { "gR",  desc  = "References → quickfix",   mode = { "n", "v" } },

        -- ── Prev [ ───────────────────────────────────────────────────
        { "[",   group = "Prev", mode = { "n", "v" } },
        { "[d",  desc  = "Prev diagnostic" },
        { "[e",  desc  = "Prev error" },
        { "[w",  desc  = "Prev warning" },
        { "[q",  desc  = "Quickfix prev" },
        { "[h",  desc  = "Git: Prev hunk" },

        -- ── Next ] ───────────────────────────────────────────────────
        { "]",   group = "Next", mode = { "n", "v" } },
        { "]d",  desc  = "Next diagnostic" },
        { "]e",  desc  = "Next error" },
        { "]w",  desc  = "Next warning" },
        { "]q",  desc  = "Quickfix next" },
        { "]h",  desc  = "Git: Next hunk" },

        -- ── Code / LSP (<leader>c) ───────────────────────────────────
        { "<leader>c",  group = "Code / LSP" },
        { "<leader>ca", desc  = "Code action (Telescope + diff preview)",  mode = { "n", "v" } },
        { "<C-.>",      desc  = "Code action",  mode = { "n", "v" } },
        { "<leader>.",  desc  = "Code action",  mode = { "n", "v" } },
        { "<leader>cr", desc  = "Rename symbol",                          mode = { "n", "v" } },
        { "<leader>rr",  desc  = "Rename symbol",                          mode = { "n", "v" } },
        { "<leader>cd", desc  = "Diagnostic float" },
        { "<leader>cD", desc  = "All diagnostics (buffer)" },
        { "<leader>cE", desc  = "Errors (buffer)" },
        { "<leader>cf", desc  = "Format document / selection", mode = { "n", "v" } },
        { "<leader>ci", desc  = "Toggle inlay hints" },
        { "<leader>cs", desc  = "Signature help" },
        { "<leader>cW", desc  = "Warnings (buffer)" },
        { "<leader>cx", desc  = "All diagnostics (workspace)" },

        -- ── Find / Telescope (<leader>f) ─────────────────────────────
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>fb", desc  = "Buffers" },
        { "<leader>ff", desc  = "Files" },
        { "<leader>fg", desc  = "Live grep" },
        { "<leader>fh", desc  = "Help tags" },
        { "<leader>fo", desc  = "Recent files" },
        { "<leader>fS", desc  = "Workspace symbols" },
        { "<leader>fs", desc  = "Document symbols" },
        { "<leader>fz", desc  = "Zoxide dirs" },

        -- ── Git (<leader>g) ──────────────────────────────────────────
        { "<leader>g",  group = "Git" },

        -- ── Debug / DAP (<leader>d) ──────────────────────────────────
        { "<leader>d",   group = "Debug (DAP)" },
        { "<leader>dc",  desc  = "Continue / Start" },
        { "<leader>dl",  desc  = "Run last config" },
        { "<leader>dr",  desc  = "Open REPL" },
        { "<leader>du",  desc  = "Toggle DAP UI" },
        { "<leader>dw",  desc  = "Watch expression",          mode = { "n", "v" } },
        { "<leader>dp",  desc  = "Peek value under cursor",   mode = { "n", "v" } },
        { "<leader>dx",  desc  = "Terminate session" },
        -- Breakpoints sub-group
        { "<leader>db",  group = "Breakpoints" },
        { "<leader>dbt", desc  = "Toggle breakpoint" },
        { "<leader>dbB", desc  = "Conditional breakpoint" },
        { "<leader>dbb", desc  = "List all (Telescope)" },
        { "<leader>dbq", desc  = "List all → quickfix" },
        { "<leader>dbc", desc  = "Clear all breakpoints" },

        -- ── .NET (<leader>n) ─────────────────────────────────────────
        { "<leader>n",   group = ".NET" },
        { "<leader>nb",  desc  = "Build project" },
        { "<leader>nB",  desc  = "Build solution" },
        { "<leader>nqb", desc  = "Build → quickfix" },
        { "<leader>nc",  desc  = "Clean" },
        { "<leader>nD",  desc  = "Workspace diagnostics" },
        -- Run
        { "<leader>nr",  desc  = "Run project" },
        { "<leader>nrp", desc  = "Run with profile" },
        { "<leader>nw",  desc  = "Watch / hot-reload" },
        -- Test
        { "<leader>nt",  desc  = "Test project" },
        { "<leader>nts", desc  = "Test solution" },
        { "<leader>nT",  desc  = "Test runner UI" },
        -- Packages sub-group
        { "<leader>np",  group = "Packages / NuGet" },
        { "<leader>npa", desc  = "Add NuGet package" },
        { "<leader>npr", desc  = "Remove NuGet package" },
        { "<leader>npo", desc  = "Outdated packages" },
        { "<leader>npv", desc  = "Project dependencies" },
        -- Misc
        { "<leader>nR",  desc  = "Restore packages" },
        { "<leader>nS",  desc  = "User secrets" },

        -- ── Quickfix (<leader>x) ─────────────────────────────────────
        { "<leader>x",  group = "Quickfix" },
        { "<leader>xo", desc  = "Open quickfix" },
        { "<leader>xc", desc  = "Close quickfix" },
      },
    },
  },

  -- ── Telescope: ignore .NET build artifacts ───────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = {
          "^bin/", "^obj/",
          "^%.git/", "^%.vs/",
          "%.dll$", "%.pdb$", "%.exe$",
          "%.cache$", "%.nupkg$",
        },
      },
    },
  },

  -- ── actions-preview: code actions in Telescope with diff preview ──────────
  {
    "aznhe21/actions-preview.nvim",
    event        = "LspAttach",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      diff = {
        algorithm        = "patience",
        ignore_whitespace = true,
      },
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy  = "vertical",
        layout_config    = {
          vertical = {
            prompt_position = "top",
            results_height  = 0.30,   -- action list
            preview_height  = 0.60,   -- diff preview of what the action does
          },
          width  = 0.80,
          height = 0.90,
        },
      },
    },
  },

  -- ── Conform: code formatter ──────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = require "configs.conform",
  },

  -- ── nvim-lspconfig: wire up LSP on_attach + extra servers ────────────────
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ── Treesitter: add C# + extras on top of NvChad defaults ────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp", "xml", "json", "toml",
        "regex", "bash", "markdown",
      },
    },
  },

  -- ── Mason: install Roslyn LSP + netcoredbg DAP adapter ───────────────────
  -- Uses mason-org registry + Crashdummyy's registry (adds "roslyn" package).
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- registries must be inside opts, not at the lazy spec level
      opts.registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",  -- provides roslyn
      }
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "roslyn",       -- C# LSP (Microsoft Roslyn language server)
        "netcoredbg",   -- .NET DAP adapter
      })
    end,
  },

  -- ── DAP: debug adapter protocol core ─────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      require "configs.dap"
    end,
  },

  -- ── DAP UI: minimal — scopes panel at bottom only ────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"

      dapui.setup({
        expand_lines = true,
        controls     = { enabled = false },   -- no play/step toolbar
        floating     = { border = "rounded" },
        render = {
          max_type_length = 60,
          max_value_lines = 200,
        },
        layouts = {
          {
            -- Bottom: scopes (live variables) + watches (typed expressions)
            elements = {
              { id = "scopes",  size = 0.65 },
              { id = "watches", size = 0.35 },
            },
            size     = 15,
            position = "bottom",
          },
        },
      })

      -- Auto open/close with debug session
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
    end,
  },

  -- ── telescope-dap: browse breakpoints, frames, configs via Telescope ───────
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("telescope").load_extension "dap"
    end,
  },

  -- ── DAP virtual text: show variable values inline ────────────────────────
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      commented                   = true,
      highlight_changed_variables = true,
    },
  },

  -- ── easy-dotnet: .NET project management, test runner, NuGet, secrets ────
  -- Prerequisite: dotnet tool install -g EasyDotnet
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft           = { "cs", "vb", "csproj", "sln", "slnx", "props" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require "configs.dotnet"
    end,
  },

  -- ── tiny-inline-diagnostic: beautiful inline diagnostics ─────────────────
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,
    config   = function()
      require "configs.tiny-inline-diagnostic"
    end,
  },

  -- ── oil.nvim: edit filesystem like a buffer ───────────────────────────────
  {
    "stevearc/oil.nvim",
    cmd          = "Oil",
    keys         = { { "-", "<cmd>Oil<cr>", desc = "Open oil (parent dir)" } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require "configs.oil"
    end,
  },

  -- ── zoxide: telescope picker for frecency-ranked directories ─────────────
  {
    "jvgrootveld/telescope-zoxide",
    keys = { { "<leader>fz", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide dirs" } },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").load_extension "zoxide"
    end,
  },

  -- ── friendly-snippets: preconfigured snippet collection for LuaSnip ───────
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
