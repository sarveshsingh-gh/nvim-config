return {

  -- ── Mason: tool / LSP installer ──────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd   = "Mason",
    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry", -- roslyn + netcoredbg
        },
      })

      -- Auto-install tools
      local ensure = {
        "stylua", "prettier", "csharpier", "xmlformatter",
        "lua-language-server", "html-lsp", "css-lsp",
        "eslint-lsp", "typescript-language-server",
        "json-lsp", "yaml-language-server",
        "netcoredbg", "roslyn",
      }
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(ensure) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end)
    end,
  },

  -- ── Completion (blink.cmp) ────────────────────────────────────────────────
  {
    "saghen/blink.cmp",
    event   = "InsertEnter",
    version = "*",
    dependencies = {
      -- VS Code snippets for every language (html, css, js, ts, lua, C#, etc.)
      { "rafamadriz/friendly-snippets", lazy = false },
    },
    opts = {
      keymap     = { preset = "default" },
      appearance = { use_nvim_hl_groups = true, nerd_font_variant = "mono" },
      sources    = { default = { "lsp", "path", "snippets", "buffer" } },
      snippets   = { preset = "default" }, -- uses vim.snippet + loads VSCode snippets from rtp
      completion = {
        accept        = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu          = { draw = { treesitter = { "lsp" } } }, -- highlight completions with treesitter
      },
    },
  },

  -- ── LSP servers (non-C#) ──────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      local lsp  = require("lspconfig")
      local caps = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim", "Snacks" } },
              workspace   = { checkThirdParty = false },
            },
          },
        },
        html        = {},
        cssls       = {},
        eslint      = {},
        ts_ls       = {},
        jsonls      = {},
        yamlls      = {},
      }

      for server, cfg in pairs(servers) do
        cfg.capabilities = caps
        lsp[server].setup(cfg)
      end
    end,
  },

  -- ── Formatter ─────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = {
      formatters_by_ft = {
        lua        = { "stylua" },
        cs         = { "csharpier" },
        xml        = { "xmlformatter" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json       = { "prettier" },
      },
      format_on_save = {
        timeout_ms   = 3000,
        lsp_fallback = true,
      },
    },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end,
        mode = { "n", "v" }, desc = "Format document" },
    },
  },
}
