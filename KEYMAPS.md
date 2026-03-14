# Neovim Keymap Reference  (LazyVim v8 + .NET)

`<leader>` = **Space**

---

## LSP — Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to Definition (Snacks picker) |
| `gD` | Go to Declaration |
| `gr` | Go to References (Snacks picker) |
| `gI` | Go to Implementation (Snacks picker) |
| `gy` | Go to Type Definition (Snacks picker) |
| `gai` | Incoming call hierarchy |
| `gao` | Outgoing call hierarchy |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<C-k>` | Signature help (insert mode) |
| `]]` | Next reference (same symbol) |
| `[[` | Prev reference (same symbol) |
| `<A-n>` | Next reference (stay in place) |
| `<A-p>` | Prev reference (stay in place) |

---

## LSP — Code Actions & Refactoring

| Key | Action |
|-----|--------|
| `rn` | Rename symbol |
| `ca` | Code action (normal + visual) |
| `<leader>cA` | Source code action |
| `<leader>cR` | Rename file |
| `<leader>cc` | Run code lens |
| `<leader>cC` | Refresh & display code lens |
| `<leader>cf` | Format document / selection |
| `<leader>cl` | LSP info (server config) |

---

## LSP — Symbols

| Key | Action |
|-----|--------|
| `<leader>ss` | Document symbols (Snacks picker) |
| `<leader>sS` | Workspace symbols (Snacks picker) |

---

## LSP — Diagnostics

| Key | Action |
|-----|--------|
| `d[` | Next diagnostic (float) |
| `d]` | Prev diagnostic (float) |
| `ds` | All diagnostics → quickfix |
| `df` | All diagnostics → Snacks picker |
| `<leader>cd` | Line diagnostics float |
| `<leader>sd` | Workspace diagnostics (picker) |
| `<leader>sD` | Buffer diagnostics (picker) |
| `]e` | Next error |
| `[e` | Prev error |
| `]w` | Next warning |
| `[w` | Prev warning |

---

## .NET / easy-dotnet  `<leader>d`

| Key | Action |
|-----|--------|
| `<leader>db` | Build — pick solution or project, live terminal |
| `<leader>dl` | Toggle build log window |
| `<leader>dq` | Toggle quickfix window (build errors/warnings) |
| `<leader>df` | Build errors in Telescope fuzzy picker |
| `<leader>dr` | dotnet run |
| `<leader>dt` | Test runner (vsplit, Rider-style) |
| `<leader>de` | Entity Framework Core menu |
| `<leader>dw` | Solution-wide workspace diagnostics |
| `<leader>dp` | Project / NuGet package view |
| `<leader>dd` | Debugger — start / continue |
| `<leader>dx` | Debugger — stop |

---

## Debugger — Visual Studio keys

| Key | Action |
|-----|--------|
| `F5` | Start / Continue |
| `Shift+F5` | Stop |
| `Ctrl+Shift+F5` | Restart |
| `F9` | Toggle breakpoint |
| `Ctrl+F9` | Conditional breakpoint (prompts expression) |
| `Shift+F9` | Log-point (print message, no pause) |
| `Ctrl+Shift+F9` | Clear all breakpoints |
| `Ctrl+Alt+B` | Browse all breakpoints in Telescope |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |
| `Ctrl+F10` | Run to cursor |
| `Shift+F10` | Hover / evaluate variable under cursor |

---

## Solution Explorer

| Key | Action |
|-----|--------|
| `Ctrl+Alt+L` | Toggle C# Solution Explorer  (VS shortcut) |

---

## Find / Search  `<leader>f` `<leader>s`

### Files

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files (project root) |
| `<leader>ff` | Find files (root) |
| `<leader>fF` | Find files (cwd) |
| `<leader>fb` | Buffers |
| `<leader>fB` | All buffers (incl. hidden) |
| `<leader>fr` | Recent files |
| `<leader>fR` | Recent files (cwd) |
| `<leader>fg` | Git files |
| `<leader>fp` | Projects |
| `<leader>fc` | Config files |
| `<leader>fn` | New file |

### Grep / Search

| Key | Action |
|-----|--------|
| `<leader>/` | Live grep (root) |
| `<leader>sg` | Live grep (root) |
| `<leader>sG` | Live grep (cwd) |
| `<leader>sw` | Grep word / selection (root) |
| `<leader>sW` | Grep word / selection (cwd) |
| `<leader>sb` | Search buffer lines |
| `<leader>sB` | Grep open buffers |

### Other pickers

| Key | Action |
|-----|--------|
| `<leader>sk` | Keymaps |
| `<leader>sh` | Help pages |
| `<leader>sH` | Highlights |
| `<leader>sm` | Marks |
| `<leader>sj` | Jumps |
| `<leader>su` | Undo tree |
| `<leader>sq` | Quickfix list |
| `<leader>sl` | Location list |
| `<leader>sR` | Resume last picker |
| `<leader>sC` | Commands |
| `<leader>sc` | Command history |
| `<leader>s/` | Search history |
| `<leader>s"` | Registers |
| `<leader>sa` | Autocmds |
| `<leader>si` | Icons |
| `<leader>sM` | Man pages |
| `<leader>sp` | Plugin specs |
| `<leader>n` | Notification history |
| `<leader>:` | Command history |
| `<leader>,` | Buffers |

---

## Git  `<leader>g`

| Key | Action |
|-----|--------|
| `<leader>gg` | Lazygit (project root) |
| `<leader>gG` | Lazygit (cwd) |
| `<leader>gb` | Git blame line |
| `<leader>gB` | Git browse (open in browser) |
| `<leader>gY` | Git browse (copy URL) |
| `<leader>gf` | Current file git history |
| `<leader>gl` | Git log |
| `<leader>gL` | Git log (cwd) |
| `<leader>gd` | Git diff hunks |
| `<leader>gD` | Git diff vs origin |
| `<leader>gs` | Git status |
| `<leader>gS` | Git stash |
| `<leader>gi` | GitHub issues (open) |
| `<leader>gI` | GitHub issues (all) |
| `<leader>gp` | GitHub PRs (open) |
| `<leader>gP` | GitHub PRs (all) |
| `]h` | Next hunk |
| `[h` | Prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghR` | Reset buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff this |

---

## Buffers  `<leader>b`

| Key | Action |
|-----|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Prev buffer |
| `<S-h>` | Prev buffer |
| `<S-l>` | Next buffer |
| `[b` / `]b` | Prev / Next buffer |
| `<leader>bb` | Switch to other buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Delete buffer and window |
| `<leader>bo` | Delete other buffers |

---

## Windows  `<leader>w`

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-Up/Down>` | Resize height |
| `<C-Left/Right>` | Resize width |
| `<leader>-` | Split below |
| `<leader>\|` | Split right |
| `<leader>wd` | Delete window |
| `<leader>wm` | Toggle window zoom (maximize) |

---

## Terminal

| Key | Action |
|-----|--------|
| `<C-/>` | Toggle terminal (root dir) |
| `<leader>ft` | Terminal (root dir) |
| `<leader>fT` | Terminal (cwd) |

---

## UI Toggles  `<leader>u`

| Key | Action |
|-----|--------|
| `<leader>uf` | Toggle auto-format (global) |
| `<leader>uF` | Toggle auto-format (buffer) |
| `<leader>uh` | Toggle inlay hints |
| `<leader>ud` | Toggle diagnostics |
| `<leader>ul` | Toggle line numbers |
| `<leader>uL` | Toggle relative numbers |
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle word wrap |
| `<leader>uc` | Toggle conceal level |
| `<leader>uT` | Toggle Treesitter highlight |
| `<leader>ub` | Toggle dark/light background |
| `<leader>uC` | Colorschemes picker |
| `<leader>uD` | Toggle dim inactive windows |
| `<leader>ua` | Toggle animations |
| `<leader>ug` | Toggle indent guides |
| `<leader>uS` | Toggle smooth scroll |
| `<leader>uZ` | Toggle window zoom |
| `<leader>uz` | Toggle zen mode |
| `<leader>ui` | Inspect position (treesitter) |
| `<leader>uI` | Inspect treesitter tree |
| `<leader>un` | Dismiss all notifications |
| `<leader>ur` | Redraw / clear search highlight |

---

## Editing

| Key | Action |
|-----|--------|
| `<C-s>` | Save file |
| `<leader>qq` | Quit all |
| `gcc` | Toggle line comment |
| `gc` + motion | Toggle comment |
| `gco` | Add comment below |
| `gcO` | Add comment above |
| `<A-j/k>` | Move line / selection up or down |
| `<` / `>` (visual) | Indent / de-indent (stays selected) |

---

## Flash (quick motion)

| Key | Action |
|-----|--------|
| `s` | Flash jump |
| `S` | Flash treesitter jump |
| `r` (operator) | Remote flash |
| `R` (operator/visual) | Treesitter search |
| `<C-s>` (command mode) | Toggle flash search |

---

## Tabs (vim tabs, not buffers)

| Key | Action |
|-----|--------|
| `<leader><tab><tab>` | New tab |
| `<leader><tab>d` | Close tab |
| `<leader><tab>]` | Next tab |
| `<leader><tab>[` | Prev tab |
| `<leader><tab>f` | First tab |
| `<leader><tab>l` | Last tab |
| `<leader><tab>o` | Close other tabs |

---

## Misc

| Key | Action |
|-----|--------|
| `<leader>l` | Open Lazy plugin manager |
| `<leader>L` | LazyVim changelog |
| `<leader>K` | Keywordprg (man/help) |
| `<leader>xq` | Toggle quickfix list |
| `<leader>xl` | Toggle location list |
| `[q` / `]q` | Prev / Next quickfix item |

---

## Quick cheatsheet — daily use

```
Navigation:   gd=def  gr=refs  gI=impl  gy=type  K=hover  gK=sig
Refactor:     <leader>cr=rename  <leader>ca=action  <leader>cf=format
Symbols:      <leader>ss=doc  <leader>sS=workspace
Diagnostics:  <leader>cd=float  ]e=next-err  [e=prev-err
Find:         <leader><space>=files  <leader>/=grep  <leader>ss=symbols
Build:        <leader>db  log:<leader>dl  qf:<leader>dq  telescope:<leader>df
Debug:        F5=go  F9=bp  F10=over  F11=into  S-F11=out
```

> **Tip:** Press `<leader>sk` to fuzzy-search all active keymaps live inside Neovim.
