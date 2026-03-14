-- DAP signs only — adapter + C# config are registered by easy-dotnet
-- automatically via debugger.auto_register_dap = true (see configs/dotnet.lua)
local dap = require "dap"

vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStopped", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "✗", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })

-- Generic attach-to-process config (works for any language)
dap.configurations.cs = dap.configurations.cs or {}
vim.list_extend(dap.configurations.cs, {
  {
    type      = "coreclr",
    name      = "Attach to process",
    request   = "attach",
    processId = require("dap.utils").pick_process,
  },
})
