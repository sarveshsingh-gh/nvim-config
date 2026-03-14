return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,
    config   = function()
      require("tiny-inline-diagnostic").setup({
        signs = {
          left       = "",
          right      = "",
          diag       = "●",
          arrow      = "    ",
          up_arrow   = "    ",
          vertical     = " │",
          vertical_end = " └",
        },
        blend = {
          factor = 0.22,
        },
      })

      -- Disable native virtual text so tiny-inline-diagnostic is the only renderer
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
