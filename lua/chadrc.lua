-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "tokyonight",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }

M.ui = {
  tabufline = {
    modules = {
      treeOffset = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft  = vim.bo[buf].filetype
          local width = vim.api.nvim_win_get_width(win)
          if ft == "dotnet_explorer" then
            local title   = "  Solution Explorer"
            local padding = string.rep(" ", math.max(0, width - vim.fn.strwidth(title) + 1))
            return "%#NvimTreeNormal#" .. title .. padding
          elseif ft == "dotnet_test_explorer" then
            local title   = "  Test Explorer"
            local padding = string.rep(" ", math.max(0, width - vim.fn.strwidth(title) + 1))
            return "%#NvimTreeNormal#" .. title .. padding
          elseif ft == "NvimTree" then
            return "%#NvimTreeNormal#" .. string.rep(" ", width + 1)
          end
        end
        return ""
      end,
    },
  },
}

return M
