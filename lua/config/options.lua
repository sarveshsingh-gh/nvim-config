local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.wrap           = false
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.termguicolors  = true
opt.showmode       = false   -- lualine shows mode
opt.pumheight      = 10
opt.splitright     = true
opt.splitbelow     = true
opt.laststatus     = 3       -- single global statusline

-- Indentation (global default — overridden per-filetype in autocmds)
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.softtabstop = 2
opt.expandtab   = true
opt.smartindent = true

-- Files
opt.swapfile   = false
opt.backup     = false
opt.undofile   = true
opt.updatetime = 1000        -- also drives auto-save CursorHold

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true

-- Completion
opt.completeopt = "menuone,noselect"
opt.shortmess:append("c")

-- Misc
opt.mouse        = "a"
opt.clipboard    = "unnamedplus"
opt.timeoutlen   = 300
opt.fileencoding = "utf-8"
