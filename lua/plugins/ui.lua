return {

  -- Icons (required by many plugins)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme                = "vscode",
        component_separators = "",
        section_separators   = "",
        globalstatus         = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { delay = 500 },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>d", group = "dotnet / debug" },
        { "<leader>r", group = "reload" },
      })
    end,
  },

  -- Inline diagnostics (replaces virtual text)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,
    config   = function()
      require("tiny-inline-diagnostic").setup({
        signs = {
          left         = "",
          right        = "",
          diag         = "●",
          arrow        = "    ",
          up_arrow     = "    ",
          vertical     = " │",
          vertical_end = " └",
        },
        blend = { factor = 0.22 },
      })
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
