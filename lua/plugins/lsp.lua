-- LSP overrides:
--   - Remove <leader>cr / <leader>ca (replaced by rn / ca in keymaps.lua)
--   - Disable virtual_text diagnostics (tiny-inline-diagnostic.nvim renders them instead)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      servers = {
        ["*"] = {
          keys = {
            { "<leader>cr", false },
            { "<leader>ca", false },
          },
        },
      },
    },
  },
}
