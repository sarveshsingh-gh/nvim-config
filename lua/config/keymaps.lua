-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

-- ---------------------------------------------------------------------------
-- Buffer tabs  (Tab = next, Shift+Tab = prev — like browser / VS tabs)
-- Note: replaces the default <C-i> jump-forward on Tab.
-- ---------------------------------------------------------------------------
map("<Tab>",   "<cmd>bnext<cr>",  "Next buffer")
map("<S-Tab>", "<cmd>bprev<cr>",  "Prev buffer")

-- ---------------------------------------------------------------------------
-- Diagnostics — d-prefix chords
-- d[  next diagnostic      d]  previous diagnostic
-- ds  all → quickfix       df  all → Snacks picker
-- ---------------------------------------------------------------------------
map("d[", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")

map("d]", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, "Prev diagnostic")

map("ds", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, "All diagnostics → quickfix")

map("df", function()
  vim.diagnostic.setqflist()
  require("telescope.builtin").quickfix()
end, "All diagnostics → Telescope")

-- ---------------------------------------------------------------------------
-- Window navigation — <C-i/j/k/l>  (normal + terminal mode)
-- Works identically to <C-h/j/k/l> (LazyVim default) but uses i for left
-- so you can navigate without leaving the home row of i/j/k/l.
-- Also ensures these work from inside a terminal buffer.
-- ---------------------------------------------------------------------------
local wins = { i = "h", j = "j", k = "k", l = "l" }
for key, dir in pairs(wins) do
  vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window" })
  vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window (terminal)" })
end

-- ---------------------------------------------------------------------------
-- Horizontal terminal — <C-t> toggles a persistent bottom-split terminal.
-- Works from normal mode and from inside the terminal itself.
-- ---------------------------------------------------------------------------
vim.keymap.set({ "n", "t" }, "<C-t>", function()
  Snacks.terminal.toggle(nil, {
    win = { position = "bottom", height = 0.30 },
  })
end, { silent = true, desc = "Toggle horizontal terminal" })
