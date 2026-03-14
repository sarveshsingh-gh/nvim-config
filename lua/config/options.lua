-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.swapfile    = false  -- no swap files
vim.opt.updatetime  = 1000   -- trigger CursorHold (auto-save) after 1 s idle

-- Restore direct-jump LSP handlers (LazyVim overrides these to open pickers)
vim.schedule(function()
  local jump = function(_, result, _, _)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No results found", vim.log.levels.INFO)
      return
    end
    local loc = vim.islist(result) and result[1] or result
    vim.lsp.util.jump_to_location(loc, "utf-8", true)
  end
  vim.lsp.handlers["textDocument/definition"]     = jump
  vim.lsp.handlers["textDocument/implementation"] = jump
  vim.lsp.handlers["textDocument/typeDefinition"] = jump
  vim.lsp.handlers["textDocument/declaration"]    = jump
end)
