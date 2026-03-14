require("tiny-inline-diagnostic").setup({
  preset = "modern",
  signs = {
    left         = "",
    right        = "",
    diag         = "●",
    arrow        = "    ",
    up_arrow     = "    ",
    vertical     = " │",
    vertical_end = " └",
  },
  blend = {
    factor = 0.22,
  },
  options = {
    show_source                = false,  -- less noise
    throttle                   = 20,
    softwrap                   = 30,
    multiple_diag_under_cursor = true,   -- show all diags when cursor on that line
    multilines = {
      enabled    = false,   -- ONLY render message on the cursor line
      always_show = false,
    },
    overflow = {
      mode = "wrap",
    },
  },
  disabled_ft = { "lazy", "mason" },
})
