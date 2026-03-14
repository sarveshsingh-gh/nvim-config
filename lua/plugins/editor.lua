return {

  -- Syntax highlighting + indentation
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "c_sharp", "xml", "json", "sql",
          "markdown", "markdown_inline",
          "html", "css", "javascript", "typescript",
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    opts   = { check_ts = true },
  },
}
