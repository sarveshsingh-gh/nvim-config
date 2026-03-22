-- blink.cmp source for .http / .rest files
-- Provides HTTP header name and value completions
local M = {}

local HEADERS = {
  "Accept", "Accept-Charset", "Accept-Encoding", "Accept-Language",
  "Authorization", "Cache-Control", "Connection", "Content-Disposition",
  "Content-Encoding", "Content-Length", "Content-Type", "Cookie",
  "Host", "If-Match", "If-Modified-Since", "If-None-Match",
  "Origin", "Pragma", "Referer", "Transfer-Encoding", "User-Agent",
  "X-API-Key", "X-Auth-Token", "X-Correlation-ID", "X-Forwarded-For",
  "X-Request-ID", "X-Requested-With",
}

local HEADER_VALUES = {
  ["Accept"]          = { "application/json", "application/xml", "text/plain", "text/html", "*/*" },
  ["Content-Type"]    = { "application/json", "application/xml", "application/x-www-form-urlencoded", "multipart/form-data", "text/plain" },
  ["Authorization"]   = { "Bearer ", "Basic ", "ApiKey " },
  ["Cache-Control"]   = { "no-cache", "no-store", "max-age=0", "must-revalidate", "public", "private" },
  ["Accept-Encoding"] = { "gzip", "deflate", "br", "identity" },
  ["Accept-Language"] = { "en-US", "en-GB", "fr", "de", "es" },
  ["Connection"]      = { "keep-alive", "close" },
}

function M.new() return setmetatable({}, { __index = M }) end

function M:get_trigger_characters() return { ":", " " } end

function M:get_completions(ctx, callback)
  local line   = ctx.line
  local col    = ctx.cursor[2]
  local before = line:sub(1, col)
  local items  = {}

  -- After "Header-Name: " → suggest values for that header
  local header, after_colon = before:match("^([%w%-]+):%s*(.*)$")
  if header and after_colon ~= nil then
    local vals = HEADER_VALUES[header] or {}
    for _, v in ipairs(vals) do
      table.insert(items, {
        label      = v,
        kind       = vim.lsp.protocol.CompletionItemKind.Value,
        insertText = v,
      })
    end
    return callback({
      items                  = items,
      is_incomplete_forward  = false,
      is_incomplete_backward = false,
    })
  end

  -- At start of line → suggest header names
  if before:match("^[%w%-]*$") then
    for _, h in ipairs(HEADERS) do
      table.insert(items, {
        label      = h,
        kind       = vim.lsp.protocol.CompletionItemKind.Keyword,
        insertText = h .. ": ",
      })
    end
  end

  callback({
    items                  = items,
    is_incomplete_forward  = false,
    is_incomplete_backward = false,
  })
end

return M
