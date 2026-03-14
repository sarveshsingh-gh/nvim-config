local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

-- ---------------------------------------------------------------------------
-- Config
-- ---------------------------------------------------------------------------
map("<leader>rv", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^plugins") or name:match("^config") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, "Reload config")

-- ---------------------------------------------------------------------------
-- Buffer tabs
-- ---------------------------------------------------------------------------
map("<Tab>",       "<cmd>bnext<cr>",                    "Next buffer")
map("<S-Tab>",     "<cmd>bprev<cr>",                    "Prev buffer")
map("<leader>x",   "<cmd>w<cr><cmd>bd<cr>",             "Save and close buffer")

-- ---------------------------------------------------------------------------
-- Window navigation — <C-h/j/k/l> + terminal mode
-- ---------------------------------------------------------------------------
local wins = { h = "h", j = "j", k = "k", l = "l" }
for key, dir in pairs(wins) do
  vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window" })
  vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window (terminal)" })
end

-- ---------------------------------------------------------------------------
-- Terminal toggle  <C-t>
-- ---------------------------------------------------------------------------
vim.keymap.set({ "n", "t" }, "<C-t>", function()
  Snacks.terminal.toggle(nil, {
    win = { position = "bottom", height = 0.30 },
  })
end, { silent = true, desc = "Toggle terminal" })

-- ---------------------------------------------------------------------------
-- Lazygit  <leader>gg
-- ---------------------------------------------------------------------------
map("<leader>gg", function()
  Snacks.terminal.toggle("lazygit", { win = { position = "float", fullscreen = true } })
end, "Lazygit")

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------
map("d[", function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next diagnostic")
map("d]", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
map("ds", function() vim.diagnostic.setqflist(); vim.cmd("copen") end,      "Diagnostics → quickfix")
map("df", function()
  vim.diagnostic.setqflist()
  require("telescope.builtin").quickfix()
end, "Diagnostics → Telescope")

-- ---------------------------------------------------------------------------
-- Oil
-- ---------------------------------------------------------------------------
map("-",          "<cmd>Oil<cr>",                          "Oil — open parent dir")
map("<leader>o",  function() require("oil").toggle_float() end, "Oil — float")

-- ---------------------------------------------------------------------------
-- Zoxide
-- ---------------------------------------------------------------------------
map("<leader>z", "<cmd>Zi<cr>", "Zoxide — interactive jump")
