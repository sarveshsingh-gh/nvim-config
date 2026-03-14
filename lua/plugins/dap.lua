return {

  -- ── Core DAP ──────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    lazy   = true,
    config = function()
      local dap = require("dap")

      -- netcoredbg adapter
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
      local dbg = vim.fn.filereadable(mason_bin) == 1 and mason_bin
                  or vim.fn.exepath("netcoredbg")

      dap.adapters.coreclr = {
        type    = "executable",
        command = dbg,
        args    = { "--interpreter=vscode" },
      }
      dap.adapters.cs = dap.adapters.coreclr

      -- Find the project DLL under bin/Debug
      local function find_dll()
        local cwd  = vim.fn.getcwd()
        local dlls = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", false, true)
        dlls = vim.tbl_filter(function(p)
          return not p:match("%.deps%.json") and not p:match("ref/")
        end, dlls)
        if #dlls == 1 then return dlls[1] end
        if #dlls > 1  then return vim.fn.input("DLL: ", dlls[1], "file") end
        return vim.fn.input("DLL: ", cwd .. "/bin/Debug/", "file")
      end

      dap.configurations.cs = {
        {
          type    = "coreclr",
          name    = "Launch (netcoredbg)",
          request = "launch",
          program = find_dll,
          env     = { ASPNETCORE_ENVIRONMENT = "Development" },
          console = "internalConsole",
        },
        {
          type      = "coreclr",
          name      = "Attach (netcoredbg)",
          request   = "attach",
          processId = function() return require("dap.utils").pick_process() end,
        },
      }
      dap.configurations.fsharp = dap.configurations.cs

      -- ── VS-style keymaps ────────────────────────────────────────────────
      local km = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
      end

      km("<F5>",       function() dap.continue() end,                         "Debug: Continue")
      km("<S-F5>",     function() dap.terminate() end,                        "Debug: Stop")
      km("<C-S-F5>",   function() dap.restart() end,                          "Debug: Restart")
      km("<F9>",       function() dap.toggle_breakpoint() end,                "Debug: Toggle breakpoint")
      km("<C-F9>",     function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Debug: Conditional BP")
      km("<S-F9>",     function() dap.set_breakpoint(nil, nil, vim.fn.input("Log: ")) end, "Debug: Log-point")
      km("<F10>",      function() dap.step_over() end,                        "Debug: Step over")
      km("<F11>",      function() dap.step_into() end,                        "Debug: Step into")
      km("<S-F11>",    function() dap.step_out() end,                         "Debug: Step out")
      km("<C-F10>",    function() dap.run_to_cursor() end,                    "Debug: Run to cursor")
      km("<C-S-F9>",   function() dap.clear_breakpoints() end,                "Debug: Clear all BPs")
      km("<C-A-b>",    function()
        require("telescope").load_extension("dap")
        require("telescope").extensions.dap.list_breakpoints()
      end, "Debug: Browse breakpoints")
    end,
  },

  -- ── DAP UI ────────────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Auto open/close
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

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

      -- DAP UI keymaps
      local m = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end
      m("n",          "<leader>du", dapui.toggle,                                        "DAP UI toggle")
      m({ "n", "v" }, "<leader>dv", function() dapui.eval(nil, { enter = true }) end,   "DAP eval")
      m("n",          "<leader>dh", function() require("dap.ui.widgets").hover() end,    "DAP hover value")
      m("n",          "Q",          function() require("dap.ui.widgets").hover() end,    "DAP hover value")
      m("v",          "Q",          function() dapui.eval() end,                         "DAP eval selection")
    end,
  },
}
