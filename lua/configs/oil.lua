require("oil").setup({
  default_file_explorer         = true,
  delete_to_trash               = true,
  skip_confirm_for_simple_edits = true,
  columns = { "icon" },
  win_options = {
    wrap         = false,
    signcolumn   = "no",
    foldcolumn   = "0",
    spell        = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },
  keymaps = {
    ["g?"]    = "actions.show_help",
    ["<CR>"]  = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-r>"] = "actions.refresh",
    ["-"]     = "actions.parent",
    ["g."]    = "actions.toggle_hidden",
  },
  view_options = {
    show_hidden    = true,
    natural_order  = true,
    is_always_hidden = function(name, _)
      return name == ".git"
    end,
  },
  float = {
    border = "rounded",
  },
})
