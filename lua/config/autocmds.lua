-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ---------------------------------------------------------------------------
-- LSP keymaps — re-bind in both normal AND visual mode on every attach.
-- Overrides LazyVim's defaults which are normal-mode only.
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_nv_keymaps", { clear = true }),
  callback = function(ev)
    local m = function(lhs, rhs, desc)
      vim.keymap.set({ "n", "v" }, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end

    m("gd", vim.lsp.buf.definition,      "Go to definition")
    m("gi", vim.lsp.buf.implementation,  "Go to implementation")
    m("gD", vim.lsp.buf.declaration,     "Go to declaration")
    m("gy", vim.lsp.buf.type_definition, "Go to type definition")
    m("gr", vim.lsp.buf.references,      "Find references")
    m("rn", vim.lsp.buf.rename,          "Rename symbol")
    m("ca", vim.lsp.buf.code_action,     "Code action")
  end,
})

-- ---------------------------------------------------------------------------
-- .NET / C# indentation — 4 spaces, no tabs (Microsoft style guide)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group   = vim.api.nvim_create_augroup("dotnet_indent", { clear = true }),
  pattern = { "cs", "fsharp", "vb", "xml", "csproj", "sln" },
  callback = function()
    vim.opt_local.tabstop     = 4
    vim.opt_local.shiftwidth  = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab   = true   -- spaces not tabs
  end,
})

-- ---------------------------------------------------------------------------
-- Auto-save — write after 1 s of inactivity (CursorHold), like VS Code.
-- Only saves normal file buffers: skips unnamed, terminals, oil, etc.
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
