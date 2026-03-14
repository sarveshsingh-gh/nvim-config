return {

  -- =========================================================================
  -- oil.nvim — edit the filesystem like a buffer
  -- `-`  opens the parent directory of the current file
  -- `<leader>o` opens oil in a floating window
  -- =========================================================================
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- load early so `-` works from any buffer
    opts = {
      -- Use oil as the default file explorer (replaces netrw)
      default_file_explorer = true,
      -- Show hidden files by default
      view_options = {
        show_hidden = true,
      },
      -- Floating window for <leader>o
      float = {
        padding = 2,
        max_width  = 90,
        max_height = 30,
      },
      -- Column decorations
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      -- Key mappings inside the oil buffer
      keymaps = {
        ["g?"]    = "actions.show_help",
        ["<CR>"]  = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["`"]     = "actions.cd",
        ["~"]     = "actions.tcd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
        ["g\\"]   = "actions.toggle_trash",
      },
      use_default_keymaps = false,
    },
    keys = {
      -- `-` opens parent dir (vim-vinegar style)
      { "-",          "<cmd>Oil<cr>",                                    desc = "Oil — open parent dir" },
      -- <leader>o opens a floating oil window
      { "<leader>o",  function() require("oil").toggle_float() end,      desc = "Oil — float explorer" },
    },
  },

  -- =========================================================================
  -- zoxide — smart directory jumping
  -- Uses your zoxide history to jump to frecent directories.
  -- <leader>z  opens an interactive picker (fzf/telescope)
  -- :Z <query>  jumps directly  |  :Zi  interactive  |  :Zg  get path
  -- Requires:  paru -S zoxide
  -- =========================================================================
  {
    "nanotee/zoxide.vim",
    cmd  = { "Z", "Zi", "Zg", "Zt" },
    keys = {
      { "<leader>z", "<cmd>Zi<cr>", desc = "Zoxide — interactive jump" },
    },
  },
}
