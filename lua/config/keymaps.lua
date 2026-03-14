local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end
local mapv = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
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
-- Buffers
-- ---------------------------------------------------------------------------
map("<Tab>",     "<cmd>bnext<cr>",       "Next buffer")
map("<S-Tab>",   "<cmd>bprev<cr>",       "Prev buffer")
map("<leader>x", "<cmd>w<cr><cmd>bd<cr>","Save and close buffer")

-- ---------------------------------------------------------------------------
-- Window navigation — <C-h/j/k/l>  (normal + terminal)
-- ---------------------------------------------------------------------------
for key, dir in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window" })
  vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><C-w>" .. dir,
    { silent = true, desc = "Go to " .. dir .. " window (terminal)" })
end

-- ---------------------------------------------------------------------------
-- Terminal / Lazygit
-- ---------------------------------------------------------------------------
vim.keymap.set({ "n", "t" }, "<C-t>", function()
  Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.30 } })
end, { silent = true, desc = "Toggle terminal" })

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
-- File explorer (Oil)
-- ---------------------------------------------------------------------------
map("-",         "<cmd>Oil<cr>",                              "Oil — parent dir")
map("<leader>o", function() require("oil").toggle_float() end,"Oil — float")

-- ---------------------------------------------------------------------------
-- Fuzzy finder (Telescope)
-- ---------------------------------------------------------------------------
map("<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
map("<leader>fg", "<cmd>Telescope live_grep<cr>",  "Live grep")
map("<leader>fb", "<cmd>Telescope buffers<cr>",    "Buffers")
map("<leader>fh", "<cmd>Telescope help_tags<cr>",  "Help tags")
map("<leader>fr", "<cmd>Telescope oldfiles<cr>",   "Recent files")

-- ---------------------------------------------------------------------------
-- Zoxide
-- ---------------------------------------------------------------------------
map("<leader>z", "<cmd>Zi<cr>", "Zoxide jump")

-- ---------------------------------------------------------------------------
-- Solution Explorer
-- ---------------------------------------------------------------------------
map("<leader>E", "<cmd>CSharpExplorer<cr>", "Solution Explorer")

-- ---------------------------------------------------------------------------
-- Format document
-- ---------------------------------------------------------------------------
mapv({ "n", "v" }, "<leader>cf",
  function() require("conform").format({ async = true }) end, "Format document")

-- ---------------------------------------------------------------------------
-- DAP — VS-style F-keys
-- ---------------------------------------------------------------------------
map("<F5>",     function() require("dap").continue() end,                          "Debug: Continue")
map("<S-F5>",   function() require("dap").terminate() end,                         "Debug: Stop")
map("<C-S-F5>", function() require("dap").restart() end,                           "Debug: Restart")
map("<F9>",     function() require("dap").toggle_breakpoint() end,                 "Debug: Toggle breakpoint")
map("<C-F9>",   function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, "Debug: Conditional BP")
map("<S-F9>",   function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log: ")) end, "Debug: Log-point")
map("<F10>",    function() require("dap").step_over() end,                         "Debug: Step over")
map("<F11>",    function() require("dap").step_into() end,                         "Debug: Step into")
map("<S-F11>",  function() require("dap").step_out() end,                          "Debug: Step out")
map("<C-F10>",  function() require("dap").run_to_cursor() end,                     "Debug: Run to cursor")
map("<C-S-F9>", function() require("dap").clear_breakpoints() end,                 "Debug: Clear all BPs")
map("<C-A-b>",  function()
  require("telescope").load_extension("dap")
  require("telescope").extensions.dap.list_breakpoints()
end, "Debug: Browse breakpoints")
map("<leader>dd", function() require("dap").continue() end,  "Debug: continue")
map("<leader>dx", function() require("dap").terminate() end, "Debug: stop")

-- ---------------------------------------------------------------------------
-- DAP UI
-- ---------------------------------------------------------------------------
map("<leader>du", function() require("dapui").toggle() end,                        "DAP UI toggle")
mapv({ "n", "v" }, "<leader>dv",
  function() require("dapui").eval(nil, { enter = true }) end,                     "DAP eval")
map("<leader>dh", function() require("dap.ui.widgets").hover() end,                "DAP hover value")
mapv("n", "Q",    function() require("dap.ui.widgets").hover() end,                "DAP hover value")
mapv("v", "Q",    function() require("dapui").eval() end,                          "DAP eval selection")
