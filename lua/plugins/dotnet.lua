-- =============================================================================
-- .NET Development Suite for Neovim (Arch Linux / LazyVim)
-- =============================================================================
-- REMINDER: Run 'dotnet tool install -g EasyDotnet' and
--           'dotnet tool install --global dotnet-ef' for full functionality.
-- Mason tools (auto-installed via mason.lua):  roslyn, netcoredbg
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Custom Build Window
-- 1. Asks whether to build the solution (.slnx/.sln) or a project (.csproj)
-- 2. Opens a bottom-split terminal with live MSBuild output
-- 3. On completion, parses errors/warnings and populates the quickfix list
-- Press q or <Esc> (normal mode) to dismiss the terminal.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Build state — persists the terminal buf/win across toggle calls
-- ---------------------------------------------------------------------------
local build_state = { buf = nil, win = nil }

local function toggle_build_log()
  -- Window open → hide it
  if build_state.win and vim.api.nvim_win_is_valid(build_state.win) then
    vim.api.nvim_win_close(build_state.win, false)
    build_state.win = nil
    return
  end
  -- Buffer alive but window was closed → re-open
  if build_state.buf and vim.api.nvim_buf_is_valid(build_state.buf) then
    local win = vim.api.nvim_open_win(build_state.buf, true, { split = "below", height = 18 })
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].wrap = false
    vim.wo[win].winfixheight = true
    build_state.win = win
    return
  end
  vim.notify("No build log — run <leader>db first.", vim.log.levels.WARN)
end

local function toggle_quickfix()
  local qf_win = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win ~= 0 and vim.api.nvim_win_is_valid(qf_win) then
    vim.cmd("cclose")
    return
  end
  if #vim.fn.getqflist() == 0 then
    vim.notify("Quickfix is empty — build first with <leader>db.", vim.log.levels.WARN)
    return
  end
  vim.cmd("botright copen")
end

local function quickfix_telescope()
  if #vim.fn.getqflist() == 0 then
    vim.notify("Quickfix is empty — build first with <leader>db.", vim.log.levels.WARN)
    return
  end
  require("telescope.builtin").quickfix()
end

-- Parse a single MSBuild output line into a quickfix entry (or nil).
-- MSBuild format: /path/file.cs(line,col): error|warning CODE: message [proj]
local function parse_msbuild_line(line)
  local file, lnum, col, severity, text = line:match("^(.+)%((%d+),(%d+)%):%s+(%a+)%s+(.-)%s*%[.-%]%s*$")
  if not file then
    return nil
  end
  severity = severity:lower()
  if severity ~= "error" and severity ~= "warning" then
    return nil
  end
  return {
    filename = file,
    lnum = tonumber(lnum),
    col = tonumber(col),
    type = severity == "error" and "E" or "W",
    text = text,
  }
end

-- Open the build terminal for a given target path (sln/csproj).
local function run_build(target_path)
  -- tee to a temp file so we get live terminal output AND can parse on exit
  local log = vim.fn.tempname()
  local cmd = ("dotnet build %q 2>&1 | tee %q"):format(target_path, log)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_open_win(buf, true, { split = "below", height = 18 })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = false
  vim.wo[win].winfixheight = true

  -- Store in module state so toggle functions can reach them
  build_state.buf = buf
  build_state.win = win

  -- Track when the user manually closes the window
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      build_state.win = nil
    end,
  })

  -- Auto-scroll during build
  local aug = vim.api.nvim_create_augroup("DotnetBuildScroll", { clear = true })
  vim.api.nvim_create_autocmd("TextChanged", {
    group = aug,
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = aug,
    buffer = buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_name, "DotnetBuildScroll")
    end,
  })

  vim.fn.termopen(cmd, {
    on_exit = function(_, code, _)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      -- Parse temp log for errors / warnings
      local qf = {}
      local f = io.open(log, "r")
      if f then
        for line in f:lines() do
          local entry = parse_msbuild_line(line)
          if entry then
            table.insert(qf, entry)
          end
        end
        f:close()
        os.remove(log)
      end

      -- Status line
      local errors = vim.tbl_filter(function(e)
        return e.type == "E"
      end, qf)
      local warnings = vim.tbl_filter(function(e)
        return e.type == "W"
      end, qf)
      local label = code == 0 and "  BUILD SUCCEEDED" or "  BUILD FAILED"
      local hl = code == 0 and "DiagnosticOk" or "DiagnosticError"
      local detail = #qf > 0 and ("  %d error(s)  %d warning(s) — quickfix open"):format(#errors, #warnings)
        or "  press q or <Esc> to close"

      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
        "",
        ("%s  (exit %d)%s"):format(label, code, detail),
      })
      local last = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_buf_add_highlight(buf, -1, hl, last - 1, 0, -1)
      vim.bo[buf].modifiable = false

      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { last, 0 })
      end

      -- Populate quickfix (do NOT auto-open — use <leader>dq / <leader>df)
      if #qf > 0 then
        vim.fn.setqflist({}, "r", {
          title = "dotnet build — " .. vim.fn.fnamemodify(target_path, ":t"),
          items = qf,
        })
      end
    end,
  })

  -- Close maps
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, desc = "Close build window" })
  end

  vim.cmd("startinsert")
end

local function dotnet_build_window()
  local cwd = vim.fn.getcwd()

  -- Discover build targets in cwd
  local targets = {}

  -- Solution first (.slnx preferred, then .sln)
  for _, pat in ipairs({ "/*.slnx", "/*.sln" }) do
    for _, path in ipairs(vim.fn.glob(cwd .. pat, false, true)) do
      table.insert(targets, {
        label = "Solution  " .. vim.fn.fnamemodify(path, ":t"),
        path = path,
      })
    end
  end

  -- Then individual projects
  for _, path in ipairs(vim.fn.glob(cwd .. "/*.csproj", false, true)) do
    table.insert(targets, {
      label = "Project   " .. vim.fn.fnamemodify(path, ":t"),
      path = path,
    })
  end

  if #targets == 0 then
    vim.notify("dotnet build: no .slnx/.sln/.csproj found in " .. cwd, vim.log.levels.ERROR)
    return
  end

  -- Skip picker when there is only one target
  if #targets == 1 then
    run_build(targets[1].path)
    return
  end

  vim.ui.select(targets, {
    prompt = "dotnet build — select target:",
    format_item = function(t)
      return t.label
    end,
  }, function(choice)
    if choice then
      run_build(choice.path)
    end
  end)
end

-- ---------------------------------------------------------------------------
-- Plugin specs
-- ---------------------------------------------------------------------------
return {

  -- =========================================================================
  -- 1. telescope.nvim
  --    Required by easy-dotnet + csharp-explorer pickers.
  --    LazyVim ships snacks.nvim for its own finders; telescope is NOT
  --    bundled by default so we declare it explicitly.
  -- =========================================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- =========================================================================
  -- 2. nvim-dap  (not bundled by LazyVim base)
  -- =========================================================================
  {
    "nvim-telescope/telescope-dap.nvim",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },

  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      local dap = require("dap")

      -- netcoredbg installed via Mason (Crashdummyy registry)
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
      local dbg = vim.fn.filereadable(mason_bin) == 1 and mason_bin or vim.fn.exepath("netcoredbg") -- system fallback
      dap.adapters.coreclr = {
        type = "executable",
        command = dbg,
        args = { "--interpreter=vscode" },
      }
      dap.adapters.cs = dap.adapters.coreclr -- alias

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Attach (netcoredbg)",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process()
          end,
        },
      }
      dap.configurations.fsharp = dap.configurations.cs

      -- ----------------------------------------------------------------
      -- Visual Studio-style DAP keybindings (global, normal mode)
      -- ----------------------------------------------------------------
      local km = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
      end

      -- F5            Start / Continue
      km("<F5>", function()
        dap.continue()
      end, "Debug: Start / Continue  (VS F5)")

      -- Shift+F5      Stop
      km("<S-F5>", function()
        dap.terminate()
      end, "Debug: Stop  (VS Shift+F5)")

      -- Ctrl+Shift+F5 Restart
      km("<C-S-F5>", function()
        dap.restart()
      end, "Debug: Restart  (VS Ctrl+Shift+F5)")

      -- F9            Toggle breakpoint
      km("<F9>", function()
        dap.toggle_breakpoint()
      end, "Debug: Toggle breakpoint  (VS F9)")

      -- Ctrl+F9       Conditional breakpoint
      km("<C-F9>", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "Debug: Conditional breakpoint  (VS Ctrl+F9)")

      -- Shift+F9      Log-point (message instead of pause)
      km("<S-F9>", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end, "Debug: Log-point  (VS Shift+F9)")

      -- F10           Step Over
      km("<F10>", function()
        dap.step_over()
      end, "Debug: Step over  (VS F10)")

      -- F11           Step Into
      km("<F11>", function()
        dap.step_into()
      end, "Debug: Step into  (VS F11)")

      -- Shift+F11     Step Out
      km("<S-F11>", function()
        dap.step_out()
      end, "Debug: Step out  (VS Shift+F11)")

      -- Ctrl+F10      Run to cursor
      km("<C-F10>", function()
        dap.run_to_cursor()
      end, "Debug: Run to cursor  (VS Ctrl+F10)")

      -- Ctrl+Alt+B    Breakpoints list in Telescope
      km("<C-A-b>", function()
        local tel = require("telescope")
        tel.load_extension("dap")
        tel.extensions.dap.list_breakpoints()
      end, "Debug: Browse breakpoints  (VS Ctrl+Alt+B)")

      -- <leader>dh    Quick Watch — hover float for value under cursor
      km("<leader>dh", function()
        require("dap.ui.widgets").hover()
      end, "Debug: Hover / evaluate  (Quick Watch)")

      -- Ctrl+D        Clear all breakpoints
      km("<C-S-F9>", function()
        dap.clear_breakpoints()
      end, "Debug: Clear all breakpoints  (VS Ctrl+Shift+F9)")
    end,
  },

  -- =========================================================================
  -- 3. roslyn.nvim — Roslyn LSP client
  --    Server installed via Mason (Crashdummyy registry: "roslyn").
  --    easy-dotnet.nvim detects this plugin and integrates automatically.
  -- =========================================================================
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- Path to the Microsoft.CodeAnalysis.LanguageServer entry-point
      -- installed by Mason (Crashdummyy registry).
      server = vim.fn.stdpath("data") .. "/mason/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer",
      config = {
        settings = {
          -- Solution-wide analysis — powers the <leader>dw diagnostics binding
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
        },
        on_attach = function(_, bufnr)
          -- Enable inlay hints per buffer when the LSP attaches
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      },
    },
  },

  -- =========================================================================
  -- 4. easy-dotnet.nvim — main .NET orchestrator
  -- =========================================================================
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp", "vb", "xml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
      "seblj/roslyn.nvim",
    },
    config = function()
      local dotnet = require("easy-dotnet")

      dotnet.setup({
        -- ----------------------------------------------------------------
        -- Terminal callback used by dotnet.run() and other shell commands
        -- ----------------------------------------------------------------
        terminal = function(path, args)
          local cmd = path .. " " .. table.concat(args, " ")
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].bufhidden = "wipe"
          local win = vim.api.nvim_open_win(buf, true, { split = "below", height = 18 })
          vim.wo[win].winfixheight = true
          vim.fn.termopen(cmd)
          vim.cmd("startinsert")
        end,

        -- ----------------------------------------------------------------
        -- Test runner (Rider-like experience)
        -- ----------------------------------------------------------------
        test_runner = {
          viewmode = "vsplit", -- mirrors a Rider tool window
          noBuild = false,
          noRestore = false,
          icons = {
            passed = "", -- nf-fa-check_circle
            failed = "", -- nf-fa-times_circle
            skipped = "󰒅", -- nf-md-skip_next
            success = "󰗡", -- nf-md-check_all
            reload = "󰑓", -- nf-md-refresh
            test = "", -- nf-fa-flask
            sln = "󰘐", -- nf-md-dot_net
            project = "", -- nf-fa-folder
            dir = "", -- nf-fa-folder_open
            package = "", -- nf-fa-archive
          },
          -- Inline stack trace for failing tests
          peek_stacktrace = true,
          -- Run individual tests directly from a .cs buffer
          enable_buffer_test_execution = true,
        },

        -- ----------------------------------------------------------------
        -- Entity Framework Core
        -- Requires: dotnet tool install --global dotnet-ef
        -- All EF commands (migrations add/remove/list, db update/drop)
        -- are surfaced through dotnet.entity_framework() — bound below.
        -- ----------------------------------------------------------------
        entity_framework = {},

        -- ----------------------------------------------------------------
        -- NuGet: outdated package virtual text + .csproj autocomplete
        -- ----------------------------------------------------------------
        outdated = {
          enable = true,
          virtual_text = true,
          prefix = "  ", -- nf-md-arrow_up_circle
        },
        csproj_autocomplete = true,

        -- ----------------------------------------------------------------
        -- Auto-bootstrap: insert namespace + skeleton class into new .cs
        -- ----------------------------------------------------------------
        auto_bootstrap = { enable = true },
      })

      -- ----------------------------------------------------------------
      -- Keybindings  (<leader>d  namespace)
      -- ----------------------------------------------------------------
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
      end

      -- Build
      map("<leader>db", dotnet_build_window, "[d]otnet [b]uild (live logs)")
      map("<leader>dl", toggle_build_log, "[d]otnet build [l]og (toggle)")
      map("<leader>dq", toggle_quickfix, "[d]otnet [q]uickfix (toggle)")
      map("<leader>df", quickfix_telescope, "[d]otnet errors in telescope [f]uzzy")
      -- Run / test / EF / diagnostics
      map("<leader>dr", function()
        dotnet.run()
      end, "[d]otnet [r]un")
      map("<leader>dt", function()
        dotnet.testrunner()
      end, "[d]otnet [t]est runner")
      map("<leader>de", function()
        dotnet.entity_framework()
      end, "[d]otnet [e]f core menu")
      map("<leader>dw", function()
        dotnet.get_workspace_diagnostics()
      end, "[d]otnet [w]orkspace diagnostics")
      map("<leader>dp", function()
        dotnet.project_view()
      end, "[d]otnet [p]roject / nuget view")
      -- Debug
      map("<leader>dd", function()
        require("dap").continue()
      end, "[d]otnet [d]ebug continue")
      map("<leader>dx", function()
        require("dap").terminate()
      end, "[d]otnet debug e[x]it")
    end,
  },

  -- =========================================================================
  -- 5. csharp-explorer.nvim — solution / project tree sidebar
  --    Ctrl+Alt+L  (Visual Studio Solution Explorer shortcut)
  -- =========================================================================
  {
    "dtrh95/csharp-explorer.nvim",
    ft = { "cs", "xml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "GustavEikaas/easy-dotnet.nvim",
    },
    config = function()
      require("csharp-explorer").setup({
        view = {
          side = "left",
          width = 35,
        },
        follow_current_file = true,
      })

      vim.keymap.set(
        "n",
        "<leader>E",
        "<cmd>CSharpExplorer<cr>",
        { desc = "Solution Explorer", silent = true }
      )
    end,
  },

  -- =========================================================================
  -- 6. nvim-treesitter — extend LazyVim's existing instance
  --    Adds C# grammar + SQL/JSON/XML for language injections inside strings.
  --    We only append to ensure_installed; LazyVim owns the base setup.
  -- =========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c_sharp", "xml", "json", "sql" })
    end,
  },
}
