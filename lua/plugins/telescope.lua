return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      -- Show only "parentfolder/filename" instead of the full path
      path_display = function(_, path)
        local tail   = require("telescope.utils").path_tail(path)
        local parent = vim.fn.fnamemodify(path, ":h:t")
        if parent == "" or parent == "." then
          return tail
        end
        return parent .. "/" .. tail
      end,
    },
  },
}
