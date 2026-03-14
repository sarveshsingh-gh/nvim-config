-- =============================================================================
-- .NET Development Suite
-- REMINDER: dotnet tool install -g EasyDotnet
--           dotnet tool install --global dotnet-ef
-- Mason: :MasonInstall roslyn netcoredbg  (Crashdummyy registry)
-- =============================================================================

-- ── Build window state ────────────────────────────────────────────────────
local build_state = { buf = nil, win = nil }

local function toggle_build_log()
  if build_state.win and vim.api.nvim_win_is_valid(build_state.win) then
    vim.api.nvim_win_close(build_state.win, false)
    build_state.win = nil
    return
  end
  if build_state.buf and vim.api.nvim_buf_is_valid(build_state.buf) then
    local win = vim.api.nvim_open_win(build_state.buf, true, { split = "below", height = 18 })
    vim.wo[win].number = false; vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"; vim.wo[win].wrap = false
    vim.wo[win].winfixheight = true
    build_state.win = win
    return
  end
  vim.notify("No build log — run <leader>db first.", vim.log.levels.WARN)
end

local function toggle_quickfix()
  local qf_win = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win ~= 0 and vim.api.nvim_win_is_valid(qf_win) then
    vim.cmd("cclose"); return
  end
  if #vim.fn.getqflist() == 0 then
    vim.notify("Quickfix is empty — build first.", vim.log.levels.WARN); return
  end
  vim.cmd("botright copen")
end

local function quickfix_telescope()
  if #vim.fn.getqflist() == 0 then
    vim.notify("Quickfix is empty — build first.", vim.log.levels.WARN); return
  end
  require("telescope.builtin").quickfix()
end

local function parse_msbuild_line(line)
  local file, lnum, col, severity, text =
    line:match("^(.+)%((%d+),(%d+)%):%s+(%a+)%s+(.-)%s*%[.-%]%s*$")
  if not file then return nil end
  severity = severity:lower()
  if severity ~= "error" and severity ~= "warning" then return nil end
  return { filename = file, lnum = tonumber(lnum), col = tonumber(col),
           type = severity == "error" and "E" or "W", text = text }
end

local function run_build(target_path)
  local log = vim.fn.tempname()
  local cmd = ("dotnet build %q 2>&1 | tee %q"):format(target_path, log)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"; vim.bo[buf].buflisted = false; vim.bo[buf].swapfile = false
  local win = vim.api.nvim_open_win(buf, true, { split = "below", height = 18 })
  vim.wo[win].number = false; vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"; vim.wo[win].wrap = false; vim.wo[win].winfixheight = true
  build_state.buf = buf; build_state.win = win

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win), once = true,
    callback = function() build_state.win = nil end,
  })
  local aug = vim.api.nvim_create_augroup("DotnetBuildScroll", { clear = true })
  vim.api.nvim_create_autocmd("TextChanged", {
    group = aug, buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = aug, buffer = buf, once = true,
    callback = function() pcall(vim.api.nvim_del_augroup_by_name, "DotnetBuildScroll") end,
  })

  vim.fn.termopen(cmd, {
    on_exit = function(_, code, _)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local qf = {}
      local f = io.open(log, "r")
      if f then
        for line in f:lines() do
          local entry = parse_msbuild_line(line)
          if entry then table.insert(qf, entry) end
        end
        f:close(); os.remove(log)
      end
      local errors   = vim.tbl_filter(function(e) return e.type == "E" end, qf)
      local warnings = vim.tbl_filter(function(e) return e.type == "W" end, qf)
      local label    = code == 0 and "  BUILD SUCCEEDED" or "  BUILD FAILED"
      local hl       = code == 0 and "DiagnosticOk" or "DiagnosticError"
      local detail   = #qf > 0
        and ("  %d error(s)  %d warning(s)"):format(#errors, #warnings)
        or  "  press q or <Esc> to close"
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, -1, -1, false,
        { "", ("%s  (exit %d)%s"):format(label, code, detail) })
      local last = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_buf_add_highlight(buf, -1, hl, last - 1, 0, -1)
      vim.bo[buf].modifiable = false
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { last, 0 })
      end
      if #qf > 0 then
        vim.fn.setqflist({}, "r", {
          title = "dotnet build — " .. vim.fn.fnamemodify(target_path, ":t"),
          items = qf,
        })
      end
    end,
  })

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end, { buffer = buf, nowait = true, desc = "Close build window" })
  end
  vim.cmd("startinsert")
end

local function dotnet_build_window()
  local cwd     = vim.fn.getcwd()
  local targets = {}
  for _, pat in ipairs({ "/*.slnx", "/*.sln" }) do
    for _, path in ipairs(vim.fn.glob(cwd .. pat, false, true)) do
      table.insert(targets, { label = "Solution  " .. vim.fn.fnamemodify(path, ":t"), path = path })
    end
  end
  for _, path in ipairs(vim.fn.glob(cwd .. "/*.csproj", false, true)) do
    table.insert(targets, { label = "Project   " .. vim.fn.fnamemodify(path, ":t"), path = path })
  end
  if #targets == 0 then
    vim.notify("dotnet build: no .slnx/.sln/.csproj in " .. cwd, vim.log.levels.ERROR); return
  end
  if #targets == 1 then run_build(targets[1].path); return end
  vim.ui.select(targets, {
    prompt = "dotnet build — select target:",
    format_item = function(t) return t.label end,
  }, function(choice) if choice then run_build(choice.path) end end)
end

-- =============================================================================
return {

  -- ── telescope-dap ──────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope-dap.nvim",
    lazy         = true,
    dependencies = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config       = function() require("telescope").load_extension("dap") end,
  },

  -- ── Roslyn LSP ─────────────────────────────────────────────────────────────
  {
    "seblj/roslyn.nvim",
    ft           = "cs",
    dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
    config = function()
      require("roslyn").setup({
        server = vim.fn.stdpath("data") ..
          "/mason/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer",
        config = {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          settings = {
            ["csharp|background_analysis"] = {
              dotnet_analyzer_diagnostics_scope = "fullSolution",
              dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_object_creation  = true,
              csharp_enable_inlay_hints_for_implicit_variable_types   = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types    = true,
              csharp_enable_inlay_hints_for_types                     = true,
              dotnet_enable_inlay_hints_for_parameters                = true,
            },
            ["csharp|completion"] = {
              dotnet_provide_regex_completions                        = true,
              dotnet_show_completion_items_from_unimported_namespaces = true,
            },
          },
          on_attach = function(_, bufnr)
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
        },
      })
    end,
  },

  -- ── easy-dotnet ────────────────────────────────────────────────────────────
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft           = { "cs", "fsharp", "vb", "xml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
      "seblj/roslyn.nvim",
    },
    config = function()
      local dotnet = require("easy-dotnet")
      dotnet.setup({
        terminal = function(path, args)
          local cmd = path .. " " .. table.concat(args, " ")
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].bufhidden = "wipe"
          local win = vim.api.nvim_open_win(buf, true, { split = "below", height = 18 })
          vim.wo[win].winfixheight = true
          vim.fn.termopen(cmd)
          vim.cmd("startinsert")
        end,
        test_runner = {
          viewmode = "vsplit",
          noBuild  = false, noRestore = false,
          icons = {
            passed = "", failed = "", skipped = "󰒅",
            success = "󰗡", reload = "󰑓", test = "",
            sln = "󰘐", project = "", dir = "", package = "",
          },
          peek_stacktrace          = true,
          enable_buffer_test_execution = true,
        },
        entity_framework    = {},
        outdated            = { enable = true, virtual_text = true, prefix = "  " },
        csproj_autocomplete = true,
        auto_bootstrap      = { enable = true },
      })

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
      end
      map("<leader>db", dotnet_build_window,               "dotnet build")
      map("<leader>dl", toggle_build_log,                  "dotnet build log (toggle)")
      map("<leader>dq", toggle_quickfix,                   "dotnet quickfix (toggle)")
      map("<leader>df", quickfix_telescope,                "dotnet errors → Telescope")
      map("<leader>dr", function() dotnet.run() end,               "dotnet run")
      map("<leader>dt", function() dotnet.testrunner() end,        "dotnet test runner")
      map("<leader>de", function() dotnet.entity_framework() end,  "dotnet EF core menu")
      map("<leader>dw", function() dotnet.get_workspace_diagnostics() end, "dotnet workspace diagnostics")
      map("<leader>dp", function() dotnet.project_view() end,      "dotnet project / NuGet view")
      map("<leader>dd", function() require("dap").continue() end,  "debug continue")
      map("<leader>dx", function() require("dap").terminate() end, "debug stop")
    end,
  },

  -- ── C# Solution Explorer ───────────────────────────────────────────────────
  {
    "dtrh95/csharp-explorer.nvim",
    ft           = { "cs", "xml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "GustavEikaas/easy-dotnet.nvim",
    },
    config = function()
      require("csharp-explorer").setup({
        view                = { side = "left", width = 35 },
        follow_current_file = true,
      })
      vim.keymap.set("n", "<leader>E", "<cmd>CSharpExplorer<cr>",
        { silent = true, desc = "Solution Explorer" })
    end,
  },

  -- ── treesitter: C# grammar ─────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c_sharp", "xml", "json", "sql" })
    end,
  },
}
