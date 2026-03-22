local M = {}

--- Quickfix text formatter — shows "parent/filename:lnum:col  text"
--- instead of the full absolute path.
function M.format(info)
  local items = info.quickfix == 1
    and vim.fn.getqflist({ id = info.id, items = 1 }).items
    or  vim.fn.getloclist(info.winid, { id = info.id, items = 1 }).items

  local result = {}
  for i = info.start_idx, info.end_idx do
    local item = items[i]
    if not item then break end

    local fname = ""
    if item.bufnr > 0 then
      local path = vim.fn.bufname(item.bufnr)
      local parts = vim.split(path, "/", { plain = true })
      -- show "parent/filename" or just "filename"
      if #parts >= 2 then
        fname = parts[#parts - 1] .. "/" .. parts[#parts]
      else
        fname = parts[#parts] or path
      end
    end

    local lnum = item.lnum > 0 and (":" .. item.lnum) or ""
    local col  = item.col  > 0 and (":" .. item.col)  or ""
    local text = vim.trim(item.text or "")

    table.insert(result, string.format("%-30s %s", fname .. lnum .. col, text))
  end
  return result
end

return M
