-- =============================================================================
-- Mason — LSP / DAP / formatter installer
-- Extends LazyVim's bundled mason.nvim with the Crashdummyy registry so that
-- `roslyn` and `netcoredbg` are available as Mason packages.
--
-- NOTE: roslyn and netcoredbg must be installed with :MasonInstall manually
--       on first setup (see comment in ensure_installed below).
-- =============================================================================
return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",  -- provides roslyn + netcoredbg
      },
      ensure_installed = {
        -- Formatters / linters
        "stylua",
        "prettier",
        "csharpier",
        "xmlformatter",

        -- Language servers
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        "eslint-lsp",
        "typescript-language-server",
        "json-lsp",
        "yaml-language-server",
        "markdown-oxide",
        "bicep-lsp",

        -- .NET tooling (from Crashdummyy registry)
        -- These cannot be auto-installed via ensure_installed on first boot;
        -- run :MasonInstall roslyn netcoredbg once after adding the registry.
        "roslyn",
        "netcoredbg",
      },
    },
  },
}
