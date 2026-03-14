return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Auto open/close the UI with the debug session
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- Minimal UI: only the scopes (variables) panel at the bottom
      dapui.setup({
        expand_lines = true,
        controls     = { enabled = false },
        floating     = { border = "rounded" },
        render = {
          max_type_length = 60,
          max_value_lines = 200,
        },
        layouts = {
          {
            elements = {
              { id = "scopes",  size = 0.6 },
              { id = "watches", size = 0.4 },
            },
            size     = 15,
            position = "bottom",
          },
        },
      })


      -- Eval keymaps
      local m = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end
      m("n",          "<leader>du", dapui.toggle,                                          "DAP UI toggle")
      m({ "n", "v" }, "<leader>dv", function() dapui.eval(nil, { enter = true }) end,   "DAP eval (enter watches)")
      -- Normal: hover float for word under cursor.  Visual: eval the selection.
      m("n",          "Q",          function() require("dap.ui.widgets").hover() end,    "DAP hover value")
      m("v",          "Q",          function() dapui.eval() end,                         "DAP eval selection")
    end,
  },
}
