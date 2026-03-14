-- easy-dotnet job indicator: shows build/run/test progress in the statusline.
-- Wrapped in a lazy getter so it works even when easy-dotnet is ft-lazy loaded.
local function dotnet_jobs()
  local ok, jobs = pcall(require, "easy-dotnet.ui-modules.jobs")
  if not ok or not jobs.lualine then return "" end
  return jobs.lualine()
end

local job_indicator = {
  dotnet_jobs,
  cond = function()
    -- Only render when easy-dotnet has been loaded
    return package.loaded["easy-dotnet"] ~= nil
  end,
}

require("lualine").setup({
  options = {
    theme                = "auto",   -- picks up the current colorscheme
    globalstatus         = true,
    always_divide_middle = true,
    component_separators = { left = "", right = "" },
    section_separators   = { left = "", right = "" },
    disabled_filetypes   = {
      statusline = { "lazy", "mason", "NvimTree", "oil" },
    },
  },
  sections = {
    lualine_a = { "mode", job_indicator },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
    lualine_x = {
      {
        -- Active LSP clients
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then return "" end
          return " " .. table.concat(vim.tbl_map(function(c) return c.name end, clients), ", ")
        end,
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "location" },
  },
  extensions = { "lazy", "mason", "oil", "nvim-dap-ui", "trouble" },
})
