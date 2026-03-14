return {

  -- ── Core DAP ──────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    lazy   = true,
    config = function()
      local dap = require("dap")

      -- netcoredbg adapter (installed via Mason)
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
    end,
  },

  -- ── DAP UI ────────────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Auto open/close UI with the debug session
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      dapui.setup({
        -- Show variable values expanded inline
        expand_lines = true,

        -- No play/step buttons in the UI (we use F-keys)
        controls = { enabled = false },

        -- Rounded borders on floating windows
        floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },

        render = {
          max_type_length = 60,   -- truncate long type names
          max_value_lines = 200,  -- max lines for multi-line values
          indent          = 1,
        },

        -- Icons for the tree expand/collapse
        icons = {
          expanded  = "",
          collapsed = "",
          circular  = "",
        },

        -- Bottom panel: Scopes (locals) + Watches side by side
        layouts = {
          {
            elements = {
              { id = "scopes",  size = 0.60 }, -- local variables
              { id = "watches", size = 0.40 }, -- custom watch expressions
            },
            size     = 15,       -- height in lines
            position = "bottom",
          },
        },

        -- Keymaps inside dap-ui element panels
        element_mappings = {
          scopes = {
            open        = "<CR>",
            expand      = "o",
            expand_all  = "O",
            collapse    = "W",
            repl        = "r",
          },
          watches = {
            open        = "<CR>",
            expand      = "o",
            remove      = "d",
            edit        = "e",
          },
        },
      })
    end,
  },
}
