-- Solution Explorer — VS Code style, full feature set
--
-- Node actions (context-aware by node kind):
--
--   SOLUTION  a=add project  D=remove project  n=new project  B=build  T=test  R=restore
--   PROJECT   a=add proj-ref  P=add NuGet  D=remove NuGet/ref  n=new item
--             b=build  r=run  t=test  v=project view (refs+NuGet)
--   DIR/FILE  <cr>=open  r=rename  d=delete
--   ALL       zM=collapse all  zR=expand all  <F5>=refresh  q=close  ?=help

local M = {}

-- ── Icons ────────────────────────────────────────────────────────────────────

-- Extension → icon (Nerd Font v3)
local EXT_ICONS = {
  -- .NET / C#
  cs        = " ",   -- nf-seti-c_sharp  (C# file)
  csproj    = " ",   -- nf-seti-visualstudio (project)
  fsproj    = " ",   -- F# project
  vbproj    = " ",
  slnx      = "󰘐 ",
  sln       = "󰘐 ",
  props     = " ",   -- nf-seti-visualstudio (MSBuild props)
  targets   = " ",
  nuspec    = " ",
  config    = " ",   -- nf-seti-settings (app.config / web.config)
  -- Web
  razor     = " ",   -- nf-md-razor
  cshtml    = " ",   -- Razor HTML
  html      = " ",   -- nf-seti-html
  htm       = " ",
  css       = " ",   -- nf-seti-css
  scss      = " ",   -- nf-seti-sass
  sass      = " ",
  less      = " ",
  js        = " ",   -- nf-seti-javascript
  mjs       = " ",
  cjs       = " ",
  ts        = " ",   -- nf-seti-typescript
  tsx       = " ",   -- nf-seti-react
  jsx       = " ",
  vue       = " ",   -- nf-seti-vue
  svelte    = " ",
  -- Data / Config
  json      = " ",   -- nf-seti-json
  jsonc     = " ",
  xml       = "󰗀 ",   -- nf-md-xml
  yaml      = " ",   -- nf-seti-yml
  yml       = " ",
  toml      = " ",   -- nf-seti-settings
  ini       = " ",
  env       = " ",
  -- Docs
  md        = " ",   -- nf-seti-markdown
  mdx       = " ",
  txt       = " ",   -- nf-seti-text
  rst       = " ",
  pdf       = " ",   -- nf-seti-pdf
  -- Scripts
  sh        = " ",   -- nf-seti-shell
  bash      = " ",
  zsh       = " ",
  fish      = " ",
  ps1       = "󰨊 ",   -- nf-md-powershell
  psm1      = "󰨊 ",
  py        = " ",   -- nf-seti-python
  rb        = " ",   -- nf-seti-ruby
  lua       = " ",   -- nf-seti-lua
  -- Database
  sql       = " ",   -- nf-seti-db
  db        = " ",
  sqlite    = " ",
  -- Images
  png       = "󰋩 ",   -- nf-md-file_image
  jpg       = "󰋩 ",
  jpeg      = "󰋩 ",
  gif       = "󰋩 ",
  svg       = "󰋩 ",
  ico       = "󰋩 ",
  webp      = "󰋩 ",
  bmp       = "󰋩 ",
  -- Archives
  zip       = "󰿺 ",
  tar       = "󰿺 ",
  gz        = "󰿺 ",
  -- Misc
  lock      = " ",   -- nf-seti-lock (packages.lock.json etc)
  log       = "󰌱 ",   -- nf-md-file_document
  gitignore = " ",
  editorconfig = " ",
  default   = " ",   -- nf-seti-default
}

-- Exact filename → icon (takes priority over extension)
local NAME_ICONS = {
  ["Dockerfile"]            = " ",   -- nf-linux-docker
  ["docker-compose.yml"]    = " ",
  ["docker-compose.yaml"]   = " ",
  [".gitignore"]            = " ",   -- nf-dev-git
  [".gitattributes"]        = " ",
  [".editorconfig"]         = " ",   -- nf-seti-settings
  [".env"]                  = " ",
  [".env.development"]      = " ",
  [".env.production"]       = " ",
  ["nuget.config"]          = " ",
  ["NuGet.Config"]          = " ",
  ["global.json"]           = " ",
  ["Directory.Build.props"] = " ",
  ["Directory.Build.targets"]=" ",
  ["Directory.Packages.props"]=" ",
  ["README.md"]             = " ",   -- nf-seti-info
  ["LICENSE"]               = "󰿃 ",   -- nf-md-license
  ["LICENSE.txt"]           = "󰿃 ",
  ["CHANGELOG.md"]          = "󰓼 ",   -- nf-md-history
  ["launchSettings.json"]   = " ",
  ["appsettings.json"]      = " ",
  ["appsettings.Development.json"] = " ",
  ["appsettings.Production.json"]  = " ",
  ["Program.cs"]            = " ",   -- entry-point star
  ["Startup.cs"]            = " ",
  ["AssemblyInfo.cs"]       = " ",
}

local I = {
  solution  = "󰘐 ",
  project   = " ",
  dir_open  = " ",
  dir_close = " ",
}

local SKIP_DIRS = { bin = true, obj = true, [".vs"] = true, [".git"] = true }
local SKIP_EXTS = { dll=true, pdb=true, exe=true, nupkg=true, cache=true, user=true, suo=true }
local WIDTH = 42

-- ── State ────────────────────────────────────────────────────────────────────

local S = {
  buf       = nil,
  win       = nil,
  sln_path  = nil,
  nodes     = {},    -- { text, indent, kind, path, dir, collapsed }
  collapsed = {},    -- paths that are collapsed
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function icon_for(name)
  if NAME_ICONS[name] then return NAME_ICONS[name] end
  -- dotfiles like .gitignore → key is the full name
  if name:sub(1,1) == "." then
    local key = name:match("^%.(.+)$") or ""
    if EXT_ICONS[key] then return EXT_ICONS[key] end
  end
  local ext = name:match("%.([^./]+)$") or ""
  return EXT_ICONS[ext] or EXT_ICONS.default
end

local function find_sln()
  for _, pat in ipairs({ "*.slnx", "*.sln" }) do
    local hits = vim.fn.glob(vim.fn.getcwd() .. "/" .. pat, false, true)
    if #hits > 0 then return hits[1] end
  end
  return nil
end

local function parse_projects(sln_path)
  local lines = vim.fn.readfile(sln_path)
  local dir   = vim.fn.fnamemodify(sln_path, ":h")
  local paths = {}
  if sln_path:match("%.slnx$") then
    for _, l in ipairs(lines) do
      local rel = l:match('Path="([^"]+%.c?f?sproj)"')
      if rel then
        table.insert(paths, vim.fn.fnamemodify(dir .. "/" .. rel:gsub("\\", "/"), ":p"))
      end
    end
  else
    for _, l in ipairs(lines) do
      local rel = l:match('"([^"]+%.c?f?sproj)"')
      if rel then
        table.insert(paths, vim.fn.fnamemodify(dir .. "/" .. rel:gsub("\\", "/"), ":p"))
      end
    end
  end
  return paths
end

local function scan_dir(dir, depth, result)
  if depth > 8 then return end
  local ok, entries = pcall(vim.fn.readdir, dir)
  if not ok then return end
  table.sort(entries, function(a, b)
    local ad = vim.fn.isdirectory(dir .. "/" .. a) == 1
    local bd = vim.fn.isdirectory(dir .. "/" .. b) == 1
    if ad ~= bd then return ad end
    return a:lower() < b:lower()
  end)
  for _, name in ipairs(entries) do
    local full   = dir .. "/" .. name
    local is_dir = vim.fn.isdirectory(full) == 1
    if is_dir then
      if not SKIP_DIRS[name] then
        table.insert(result, { name=name, path=full, is_dir=true, depth=depth })
        if not S.collapsed[full] then
          scan_dir(full, depth+1, result)
        end
      end
    else
      local ext = name:match("%.([^.]+)$") or ""
      if not SKIP_EXTS[ext] then
        table.insert(result, { name=name, path=full, is_dir=false, depth=depth })
      end
    end
  end
end

-- ── Build tree ────────────────────────────────────────────────────────────────

local function build_nodes()
  local nodes = {}
  local sln   = S.sln_path
  local name  = vim.fn.fnamemodify(sln, ":t:r")

  -- Solution root
  table.insert(nodes, {
    text      = I.solution .. name,
    indent    = 0,
    kind      = "solution",
    path      = sln,
    collapsed = S.collapsed[sln] or false,
  })

  if S.collapsed[sln] then return nodes end

  for _, proj_path in ipairs(parse_projects(sln)) do
    if vim.fn.filereadable(proj_path) == 1 then
      local proj_name = vim.fn.fnamemodify(proj_path, ":t:r")
      local proj_dir  = vim.fn.fnamemodify(proj_path, ":h")
      local is_coll   = S.collapsed[proj_path] or false

      table.insert(nodes, {
        text      = I.project .. proj_name,
        indent    = 1,
        kind      = "project",
        path      = proj_path,
        dir       = proj_dir,
        collapsed = is_coll,
      })

      if not is_coll then
        local entries = {}
        scan_dir(proj_dir, 0, entries)
        for _, e in ipairs(entries) do
          local ico = e.is_dir
            and (S.collapsed[e.path] and I.dir_close or I.dir_open)
            or icon_for(e.name)
          table.insert(nodes, {
            text      = ico .. e.name,
            indent    = 2 + e.depth,
            kind      = e.is_dir and "dir" or "file",
            path      = e.path,
            collapsed = S.collapsed[e.path] or false,
          })
        end
      end
    end
  end

  return nodes
end

-- ── Render ────────────────────────────────────────────────────────────────────

local INDENT = "  "

local function render()
  if not S.buf or not vim.api.nvim_buf_is_valid(S.buf) then return end
  local lines = {}
  for _, n in ipairs(S.nodes) do
    table.insert(lines, INDENT:rep(n.indent) .. n.text)
  end
  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
  vim.bo[S.buf].modifiable = false
end

local function refresh()
  S.nodes = build_nodes()
  render()
end

-- ── Nearest project above cursor ──────────────────────────────────────────────

local function current_node()
  if not S.win then return nil end
  local row = vim.api.nvim_win_get_cursor(S.win)[1]
  return S.nodes[row]
end

local function nearest_project(from_row)
  for i = from_row, 1, -1 do
    local n = S.nodes[i]
    if n and n.kind == "project" then return n end
  end
  return nil
end

-- ── Floating confirm/input helpers ───────────────────────────────────────────

local function confirm(msg, cb)
  vim.ui.input({ prompt = msg .. " [y/N]: " }, function(ans)
    if ans and ans:lower() == "y" then cb() end
  end)
end

-- ── Actions ───────────────────────────────────────────────────────────────────

-- Run a dotnet CLI command in a split terminal
local function run_cmd(args, on_exit)
  vim.cmd("botright 12split")
  local term_win = vim.api.nvim_get_current_win()
  local cmd      = "dotnet " .. table.concat(args, " ")
  vim.fn.termopen(cmd, {
    on_exit = function(_, code)
      if on_exit then on_exit(code) end
      vim.schedule(refresh)
    end,
  })
  vim.cmd("startinsert")
  vim.api.nvim_set_current_win(S.win)
end

local function get_dotnet(mod)
  local ok, m = pcall(require, "easy-dotnet." .. mod)
  return ok and m or nil
end

-- ── Solution-level actions ────────────────────────────────────────────────────

local function action_add_project()
  local sln = get_dotnet("parsers.sln-parse")
  if sln then
    coroutine.wrap(function() sln.add_project_to_solution(S.sln_path) end)()
    vim.defer_fn(refresh, 800)
  end
end

local function action_remove_project()
  local sln = get_dotnet("parsers.sln-parse")
  if sln then
    coroutine.wrap(function() sln.remove_project_from_solution(S.sln_path) end)()
    vim.defer_fn(refresh, 800)
  end
end

local function action_new_project()
  local new = get_dotnet("actions.new")
  if new then
    coroutine.wrap(function() new.new() end)()
    vim.defer_fn(refresh, 1500)
  end
end

local function action_build_solution()
  local act = get_dotnet("actions.build")
  if act then coroutine.wrap(function() act.build_solution() end)() end
end

local function action_test_solution()
  local act = get_dotnet("actions.test")
  if act then coroutine.wrap(function() act.test_solution() end)() end
end

local function action_restore_solution()
  run_cmd({ "restore", vim.fn.fnameescape(S.sln_path) })
end

-- ── Project-level actions ─────────────────────────────────────────────────────

local function action_add_project_ref(proj_node)
  local mappings = get_dotnet("csproj-mappings")
  if mappings then
    coroutine.wrap(function()
      mappings.add_project_reference(proj_node.path, function() refresh() end)
    end)()
  end
end

local function action_add_nuget(proj_node)
  local nuget = get_dotnet("nuget")
  if nuget then
    coroutine.wrap(function()
      nuget.search_nuget(proj_node.path, false)
    end)()
    vim.defer_fn(refresh, 1000)
  end
end

local function action_remove_nuget_or_ref(proj_node)
  -- Opens easy-dotnet project view where user can pick (r)emove on any ref
  local pv = get_dotnet("project-view")
  if pv then
    local csproj = get_dotnet("parsers.csproj-parse")
    if csproj then
      local project = csproj.get_project_from_project_file(proj_node.path)
      coroutine.wrap(function() pv.render(project, S.sln_path) end)()
    end
  end
end

local function action_new_item(proj_node)
  local new = get_dotnet("actions.new")
  if new then
    coroutine.wrap(function() new.create_new_item(proj_node.dir) end)()
    vim.defer_fn(refresh, 800)
  end
end

local function action_build_project(proj_node)
  run_cmd({ "build", vim.fn.fnameescape(proj_node.path) })
end

local function action_run_project(proj_node)
  run_cmd({ "run", "--project", vim.fn.fnameescape(proj_node.path) })
end

local function action_test_project(proj_node)
  run_cmd({ "test", vim.fn.fnameescape(proj_node.path) })
end

local function action_project_view(proj_node)
  local pv    = get_dotnet("project-view")
  local csproj = get_dotnet("parsers.csproj-parse")
  if pv and csproj then
    local project = csproj.get_project_from_project_file(proj_node.path)
    coroutine.wrap(function() pv.render(project, S.sln_path) end)()
  end
end

-- ── File/dir actions ──────────────────────────────────────────────────────────

local function action_open_file(node)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, w in ipairs(wins) do
    if w ~= S.win then
      vim.api.nvim_set_current_win(w)
      break
    end
  end
  vim.cmd("edit " .. vim.fn.fnameescape(node.path))
end

local function action_rename(node)
  local old_name = vim.fn.fnamemodify(node.path, ":t")
  vim.ui.input({ prompt = "Rename to: ", default = old_name }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then return end
    local new_path = vim.fn.fnamemodify(node.path, ":h") .. "/" .. new_name
    local ok, err  = os.rename(node.path, new_path)
    if ok then
      vim.notify("[SolnExplorer] Renamed → " .. new_name, vim.log.levels.INFO)
      refresh()
    else
      vim.notify("[SolnExplorer] Rename failed: " .. (err or ""), vim.log.levels.ERROR)
    end
  end)
end

local function action_delete(node)
  local name = vim.fn.fnamemodify(node.path, ":t")
  confirm("Delete " .. name .. "?", function()
    if node.kind == "dir" then
      vim.fn.delete(node.path, "rf")
    else
      vim.fn.delete(node.path)
    end
    vim.notify("[SolnExplorer] Deleted " .. name, vim.log.levels.INFO)
    refresh()
  end)
end

-- ── Help popup ────────────────────────────────────────────────────────────────

local function show_help()
  local lines = {
    "  Solution Explorer — Keymaps",
    "  ══════════════════════════════════════════",
    "",
    "  ── Global (any node) ──────────────────────",
    "  <cr>        open file  /  toggle fold",
    "  <space>     toggle fold",
    "  zM          collapse all nodes",
    "  zR          expand  all nodes",
    "  <F5>        refresh tree",
    "  q           close Solution Explorer",
    "  <M-S-p>     Dotnet command palette",
    "  ?           this help",
    "",
    "  ── SOLUTION node ──────────────────────────",
    "  a           add existing project",
    "  D           remove project from solution",
    "  n           new project (wizard)",
    "  B           build solution",
    "  T           test  solution",
    "  R           dotnet restore solution",
    "",
    "  ── PROJECT node ───────────────────────────",
    "  a           add project reference",
    "  P           add NuGet package",
    "  D           project view → remove ref / pkg",
    "  n           new file / class in project",
    "  b           build project",
    "  r           run   project",
    "  t           test  project",
    "  v           project view (refs + NuGet)",
    "",
    "  ── FILE / DIR node ────────────────────────",
    "  <cr>        open file",
    "  r           rename",
    "  d           delete (with confirm)",
    "",
    "  ── Toggle from anywhere in Neovim ─────────",
    "  <leader>ne  toggle Solution Explorer",
    "  <leader>nE  reveal current file in tree",
    "",
    "  Press  q  or  <Esc>  to close this help",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local w = math.max(48, #lines[2] + 2)
  local h = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = w,
    height   = h,
    col      = math.floor((vim.o.columns - w) / 2),
    row      = math.floor((vim.o.lines - h) / 2),
    style    = "minimal",
    border   = "rounded",
    title    = " Help ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end, { buffer=buf })
  vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer=buf })
end

-- ── Context-aware dispatch ────────────────────────────────────────────────────

-- `key` pressed — dispatch based on current node kind
local DISPATCH = {
  -- ── Common ───────────────────────────────────────────────────────
  ["<cr>"] = function(node, _)
    if node.kind == "file" then
      action_open_file(node)
    else
      S.collapsed[node.path] = not S.collapsed[node.path]
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,
  ["<space>"] = function(node, _)
    if node.kind ~= "file" then
      S.collapsed[node.path] = not S.collapsed[node.path]
      local row = vim.api.nvim_win_get_cursor(S.win)[1]
      refresh()
      pcall(vim.api.nvim_win_set_cursor, S.win, { row, 0 })
    end
  end,

  -- ── Solution ──────────────────────────────────────────────────────
  ["a"] = function(node, row)
    if     node.kind == "solution" then action_add_project()
    elseif node.kind == "project"  then action_add_project_ref(node)
    end
  end,
  ["D"] = function(node, row)
    if     node.kind == "solution" then action_remove_project()
    elseif node.kind == "project"  then action_remove_nuget_or_ref(node)
    elseif node.kind == "file" or node.kind == "dir" then action_delete(node)
    end
  end,
  ["n"] = function(node, row)
    if     node.kind == "solution" then action_new_project()
    elseif node.kind == "project"  then action_new_item(node)
    else
      local proj = nearest_project(row)
      if proj then action_new_item(proj) end
    end
  end,
  ["B"] = function(node, row)
    if node.kind == "solution" then action_build_solution()
    else
      local proj = nearest_project(row)
      if proj then action_build_project(proj) end
    end
  end,
  ["T"] = function(node, row)
    if node.kind == "solution" then action_test_solution()
    else
      local proj = nearest_project(row)
      if proj then action_test_project(proj) end
    end
  end,
  ["R"] = function(node, _)
    if node.kind == "solution" then action_restore_solution()
    else refresh() end
  end,

  -- ── Project ────────────────────────────────────────────────────────
  ["P"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_add_nuget(proj) end
  end,
  ["b"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_build_project(proj) end
  end,
  ["r"] = function(node, row)
    if node.kind == "file" or node.kind == "dir" then
      action_rename(node)
    else
      local proj = node.kind == "project" and node or nearest_project(row)
      if proj then action_run_project(proj) end
    end
  end,
  ["t"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_test_project(proj) end
  end,
  ["v"] = function(node, row)
    local proj = node.kind == "project" and node or nearest_project(row)
    if proj then action_project_view(proj) end
  end,

  -- ── File ───────────────────────────────────────────────────────────
  ["d"] = function(node, _)
    if node.kind == "file" or node.kind == "dir" then action_delete(node) end
  end,

  -- ── Global ─────────────────────────────────────────────────────────
  ["zM"] = function(_, _)
    for _, n in ipairs(S.nodes) do
      if n.kind ~= "file" then S.collapsed[n.path] = true end
    end
    refresh()
  end,
  ["zR"] = function(_, _)
    S.collapsed = {}
    refresh()
  end,
  ["?"] = function(_, _) show_help() end,
}

-- ── Window / buffer setup ─────────────────────────────────────────────────────

local function setup_keymaps()
  local o = { noremap=true, silent=true, buffer=S.buf }

  for key, fn in pairs(DISPATCH) do
    vim.keymap.set("n", key, function()
      local row  = vim.api.nvim_win_get_cursor(S.win)[1]
      local node = S.nodes[row]
      if node then fn(node, row) end
    end, o)
  end

  vim.keymap.set("n", "<F5>", refresh,       o)
  vim.keymap.set("n", "q",    M.close,        o)
  vim.keymap.set("n", "<M-S-p>", "<cmd>Dotnet<cr>", o)
end

local function open_win()
  S.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[S.buf].filetype  = "sln_explorer"
  vim.bo[S.buf].bufhidden = "wipe"
  vim.bo[S.buf].modifiable = false
  vim.api.nvim_buf_set_name(S.buf, "[Solution Explorer]")

  vim.cmd("topleft " .. WIDTH .. "vsplit")
  S.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(S.win, S.buf)

  local wo = vim.wo[S.win]
  wo.number = false; wo.relativenumber = false
  wo.signcolumn = "no"; wo.foldcolumn = "0"
  wo.wrap = false; wo.winfixwidth = true
  wo.cursorline = true

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = S.buf, once = true,
    callback = function() S.win = nil; S.buf = nil end,
  })
end

-- ── Public API ────────────────────────────────────────────────────────────────

function M.close()
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_win_close(S.win, true)
  end
  S.win = nil; S.buf = nil
end

function M.open()
  S.sln_path = find_sln()
  if not S.sln_path then
    vim.notify("[SolnExplorer] No .slnx / .sln found in " .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  open_win()
  setup_keymaps()
  refresh()
end

function M.toggle()
  if S.win and vim.api.nvim_win_is_valid(S.win) then M.close()
  else M.open() end
end

function M.reveal()
  if not S.win or not vim.api.nvim_win_is_valid(S.win) then M.open() end
  local cur = vim.api.nvim_buf_get_name(
    vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()))
  for i, n in ipairs(S.nodes) do
    if n.path == cur then
      vim.api.nvim_win_set_cursor(S.win, { i, 0 })
      return
    end
  end
end

return M
