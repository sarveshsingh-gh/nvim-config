return {

  -- File explorer (edit filesystem like a buffer)
  {
    "stevearc/oil.nvim",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options          = { show_hidden = true },
        float = {
          padding    = 2,
          max_width  = 90,
          max_height = 30,
        },
        columns = { "icon", "permissions", "size", "mtime" },
        keymaps = {
          ["g?"]    = "actions.show_help",
          ["<CR>"]  = "actions.select",
          ["<C-v>"] = "actions.select_vsplit",
          ["<C-s>"] = "actions.select_split",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-r>"] = "actions.refresh",
          ["-"]     = "actions.parent",
          ["_"]     = "actions.open_cwd",
          ["`"]     = "actions.cd",
          ["g."]    = "actions.toggle_hidden",
        },
        use_default_keymaps = false,
      })

      -- Truncated winbar: show …/parent/current for deep paths
      _G.OilTitle = function()
        local ok, oil = pcall(require, "oil")
        if not ok then return "" end
        local dir = oil.get_current_dir()
        if not dir then return "" end
        dir = dir:gsub(vim.env.HOME, "~"):gsub("/$", "")
        local parts = vim.split(dir, "/", { plain = true, trimempty = true })
        if #parts > 3 then
          return "  .../" .. table.concat({ parts[#parts - 1], parts[#parts] }, "/")
        end
        return "  " .. dir
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern  = "oil://*",
        callback = function() vim.wo.winbar = "%!v:lua.OilTitle()" end,
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        -- Show parent/filename only
        path_display = function(_, path)
          local tail   = require("telescope.utils").path_tail(path)
          local parent = vim.fn.fnamemodify(path, ":h:t")
          if parent == "" or parent == "." then return tail end
          return parent .. "/" .. tail
        end,
      },
    },
  },

  -- Snacks: terminal toggle + lazygit float
  {
    "folke/snacks.nvim",
    lazy  = false,
    priority = 900,
    opts = {
      terminal = { enabled = true },
      picker   = {
        enabled   = true,
        formatters = {
          file = {
            truncate  = "left",
            min_width = 30,
          },
        },
      },
    },
  },

  -- Zoxide directory jumping
  {
    "nanotee/zoxide.vim",
    cmd  = { "Z", "Zi", "Zg", "Zt" },
  },
}
