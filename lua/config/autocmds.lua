-- ---------------------------------------------------------------------------
-- LSP keymaps — buffer-local, n + v mode, set on every attach.
-- No LazyVim overrides here — vim.lsp.buf.* jumps directly by default.
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(ev)
    local m = function(lhs, rhs, desc)
      vim.keymap.set({ "n", "v" }, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end
    m("gd", vim.lsp.buf.definition,      "Go to definition")
    m("gm", vim.lsp.buf.implementation,  "Go to implementation")
    m("gD", vim.lsp.buf.declaration,     "Go to declaration")
    m("gy", vim.lsp.buf.type_definition, "Go to type definition")
    m("gr", vim.lsp.buf.references,      "Find references")
    m("K",  vim.lsp.buf.hover,           "Hover docs")
    m("rn", vim.lsp.buf.rename,          "Rename symbol")
    m("ca", vim.lsp.buf.code_action,     "Code action")

    -- Inlay hints toggle
    vim.keymap.set("n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, { buffer = ev.buf, silent = true, desc = "Toggle inlay hints" })
  end,
})

-- ---------------------------------------------------------------------------
-- .NET / C# indentation — 4 spaces (Microsoft style guide)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group   = vim.api.nvim_create_augroup("dotnet_indent", { clear = true }),
  pattern = { "cs", "fsharp", "vb", "xml", "csproj", "sln" },
  callback = function()
    vim.opt_local.tabstop     = 4
    vim.opt_local.shiftwidth  = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab   = true
  end,
})

-- ---------------------------------------------------------------------------
-- Auto-save — 1 s idle, named file buffers only
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype == ""
      and vim.bo[buf].modifiable
      and vim.fn.expand("%") ~= ""
      and vim.bo[buf].modified
    then
      vim.cmd("silent! write")
    end
  end,
})
