-- Formatters per filetype.
-- C# formatting is handled by Roslyn LSP (via autocmd in autocmds.lua),
-- so we only need formatters for other filetypes here.
return {
  formatters_by_ft = {
    lua  = { "stylua" },
    json = { "prettierd", stop_after_first = true },
    xml  = { "xmlformat" },
    -- cs = {},  -- Roslyn handles C# formatting; leave blank
  },
  format_on_save = {
    timeout_ms   = 500,
    lsp_fallback = true,
  },
}
