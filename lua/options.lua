require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- Indentation (C# standard: 4 spaces)
o.tabstop    = 4
o.shiftwidth = 4
o.expandtab  = true

-- UI
o.relativenumber = true
o.cursorlineopt  = "both"
o.scrolloff      = 8
o.sidescrolloff  = 8
o.wrap           = false

-- Files
o.undofile = true
o.swapfile = false
o.backup   = false

-- Search
o.hlsearch = false

-- Clipboard (system)
o.clipboard = "unnamedplus"

-- Faster completion popups
o.updatetime = 200

-- Quickfix: show only parent/filename instead of full path
vim.o.quickfixtextfunc = "v:lua.require'utils.qf'.format"

-- Shell
if vim.fn.has("win32") == 1 then
  opt.shell     = "powershell"
  opt.shellcmdflag = "-NoLogo -NonInteractive -Command"
  opt.shellquote   = ""
  opt.shellxquote  = ""
else
  opt.shell = "bash"
end

-- .NET / C#: treat csproj/sln/props as xml for treesitter fallback
vim.filetype.add({
  extension = {
    csproj  = "xml",
    props   = "xml",
    targets = "xml",
  },
})
