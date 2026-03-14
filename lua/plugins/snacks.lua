return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      formatters = {
        file = {
          filename_first = false, -- path then filename
          truncate       = "left", -- keep the end: …/parent/file.cs
          min_width      = 30,    -- show roughly one parent folder + filename
          git_status_hl  = true,
        },
      },
    },
  },
}
