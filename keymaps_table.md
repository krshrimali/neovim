# Neovim Keymap Documentation

This document provides a comprehensive list of all keymaps configured in this Neovim setup.

## Table of Contents
- [General Navigation](#general-navigation)
- [LSP (Language Server Protocol)](#lsp-language-server-protocol)
- [File Navigation](#file-navigation)
- [Window Management](#window-management)
- [Terminal](#terminal)
- [Git](#git)
- [Text Manipulation](#text-manipulation)
- [NvimTree](#nvimtree)
- [Telescope](#telescope)
- [Options](#options)
- [Session Management](#session-management)
- [Search and Replace](#search-and-replace)
- [Code Runner](#code-runner)
- [Diagnostics](#diagnostics)
- [Find Commands](#find-commands)
- [Miscellaneous](#miscellaneous)

## General Navigation

| Keymap | Mode | Description |
|--------|------|-------------|
| `jk` | Insert | Exit insert mode |
| `<C-a>` | Normal | Select all text |
| `w` | Normal/Operator/Visual | Smart word motion forward |
| `e` | Normal/Operator/Visual | Smart word motion to end |
| `b` | Normal/Operator/Visual | Smart word motion backward |
| `ge` | Normal/Operator/Visual | Smart word motion backward to end |
| `<S-l>` | Normal | Next buffer |
| `<S-h>` | Normal | Previous buffer |
| `K` | Normal | Show documentation |

## LSP (Language Server Protocol)

| Keymap | Mode | Description |
|--------|------|-------------|
| `gd` | Normal | Go to definition |
| `gR` | Normal | Show references |
| `gi` | Normal | Go to implementation |
| `go` | Normal | Show outgoing calls |
| `<F11>` | Normal | Show references |
| `<F12>` | Normal | Go to definition |
| `<C-s>` | Normal | Document symbol |
| `<leader>gpd` | Normal | Preview definition |
| `<leader>gpi` | Normal | Preview implementation |
| `<leader>gpD` | Normal | Preview declaration |
| `<leader>gP` | Normal | Close all preview windows |
| `<leader>gpr` | Normal | Preview references |
| `<leader>lf` | Visual | Format selected code |
| `<leader>lgv` | Normal | Open definition in vertical split |
| `<leader>lgh` | Normal | Open definition in horizontal split |
| `<leader>lA` | Normal | CodeLens Action |
| `<leader>la` | Normal | Code Action |
| `<leader>ld` | Normal | Document diagnostics |
| `<leader>lw` | Normal | Workspace Diagnostics |
| `<leader>lF` | Normal | Toggle Autoformat |
| `<leader>li` | Normal | Mason Log Info |
| `<leader>lH` | Normal | Toggle Doc Highlight |
| `<leader>lI` | Normal | Mason Installer Info |
| `<leader>lj` | Normal | Next Diagnostic |
| `<leader>lk` | Normal | Previous Diagnostic |
| `<leader>lev` | Normal | Toggle Virtual Lines |
| `<leader>leV` | Normal | Toggle Virtual Text |
| `<leader>lo` | Normal | Toggle Outline |
| `<leader>lq` | Normal | Diagnostics to Quickfix |
| `<leader>lQ` | Normal | Quickfix in Telescope |
| `<leader>lR` | Normal | Rename symbol |
| `<leader>lr` | Normal | Show References |
| `<leader>ls` | Normal | Document Symbols |
| `<leader>lS` | Normal | Workspace Symbols |
| `<leader>lgg` | Normal | Goto Preview Definition |
| `<leader>lgt` | Normal | Goto Preview Type Definition |
| `<leader>lgi` | Normal | Goto Preview Implementation |
| `<leader>lgr` | Normal | Goto Preview References |
| `<leader>lgc` | Normal | Close all preview windows |
| `<leader>lt` | Normal | Toggle Diagnostics |
| `<leader>lu` | Normal | Unlink Snippet |

## File Navigation

| Keymap | Mode | Description |
|--------|------|-------------|
| `-` | Normal | Open parent directory (Oil) |
| `<C-p>` | Normal | Open projects |
| `<leader><leader>f` | Normal | Find files in current directory |
| `<leader><leader>g` | Normal | Live grep in current directory |
| `<leader><leader>s` | Normal | Open command line |

## Window Management

| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-w><left>` | Normal | Decrease window width |
| `<C-w><right>` | Normal | Increase window width |
| `<C-w><up>` | Normal | Increase window height |
| `<C-w><down>` | Normal | Decrease window height |

## Terminal

| Keymap | Mode | Description |
|--------|------|-------------|
| `<esc>` | Terminal | Exit terminal mode |
| `jk` | Terminal | Exit terminal mode |
| `<C-h>` | Terminal | Move to left window |
| `<C-j>` | Terminal | Move to bottom window |
| `<C-k>` | Terminal | Move to top window |
| `<C-l>` | Terminal | Move to right window |
| `<m-1>` | Normal/Insert | Float terminal |
| `<m-2>` | Normal/Insert | Vertical terminal |
| `<m-3>` | Normal/Insert | Horizontal terminal |

## Git

| Keymap | Mode | Description |
|--------|------|-------------|
| `glb` | Normal | Git blame line |
| `<leader>gy` | Normal/Visual | Copy git URL |
| `<leader>gg` | Normal | Open Lazygit |
| `<leader>gj` | Normal | Next Hunk |
| `<leader>gk` | Normal | Previous Hunk |
| `<leader>gll` | Normal | Toggle Blame Virtual Text |
| `<leader>glf` | Normal | Show Blame column |
| `<leader>glg` | Normal | Show Blame line preview |
| `<leader>gp` | Normal | Preview Hunk |
| `<leader>gr` | Normal | Reset Hunk |
| `<leader>gR` | Normal | Reset Buffer |
| `<leader>gs` | Normal | Stage Hunk |
| `<leader>gu` | Normal | Undo Stage Hunk |
| `<leader>go` | Normal | Open changed file |
| `<leader>gd` | Normal | Show diff |
| `<leader>Gl` | Normal | Toggle Git blame |
| `<leader>Gc` | Normal | Copy SHA URL of commit |
| `<leader>Go` | Normal | Open commit URL |

## Text Manipulation

| Keymap | Mode | Description |
|--------|------|-------------|
| `+` | Normal | Increment number |
| `-` | Normal | Decrement number |
| `dw` | Normal | Delete word backwards |
| `<S-d>` | Normal | Move line down |
| `<S-u>` | Normal | Move line up |
| `<` | Visual | Decrease indent |
| `>` | Visual | Increase indent |
| `p` | Visual | Paste without yanking |
| `F` | Visual | Move selection down |
| `U` | Visual | Move selection up |
| `<leader>d` | Normal/Visual | Delete without yanking |
| `<leader>s` | Normal | Search and replace word under cursor |

## NvimTree

| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-]>` | Normal | Change root to node |
| `<C-e>` | Normal | Open in place |
| `<C-k>` | Normal | Show info popup |
| `<C-r>` | Normal | Rename omitting filename |
| `<C-t>` | Normal | Open in new tab |
| `<C-v>` | Normal | Open in vertical split |
| `<C-x>` | Normal | Open in horizontal split |
| `<BS>` | Normal | Close directory |
| `<CR>` | Normal | Open |
| `<Tab>` | Normal | Open preview |
| `>` | Normal | Next sibling |
| `<` | Normal | Previous sibling |
| `.` | Normal | Run command |
| `-` | Normal | Up to parent |
| `a` | Normal | Create |
| `bmv` | Normal | Move bookmarked |
| `B` | Normal | Toggle no buffer |
| `c` | Normal | Copy node |
| `C` | Normal | Toggle git clean |
| `[c` | Normal | Previous git item |
| `]c` | Normal | Next git item |
| `d` | Normal | Delete |
| `D` | Normal | Trash |
| `E` | Normal | Expand all |
| `e` | Normal | Rename basename |
| `]e` | Normal | Next diagnostic |
| `[e` | Normal | Previous diagnostic |
| `F` | Normal | Clear filter |
| `f` | Normal | Filter |
| `g?` | Normal | Toggle help |
| `gy` | Normal | Copy absolute path |
| `H` | Normal | Toggle dotfiles |
| `I` | Normal | Toggle git ignore |
| `J` | Normal | Last sibling |
| `K` | Normal | First sibling |
| `m` | Normal | Toggle bookmark |
| `o` | Normal | Open |
| `O` | Normal | Open without window picker |
| `p` | Normal | Paste |
| `P` | Normal | Parent directory |
| `q` | Normal | Close |
| `r` | Normal | Rename |
| `R` | Normal | Refresh |
| `s` | Normal | Run system |
| `S` | Normal | Search node |
| `U` | Normal | Toggle hidden |
| `W` | Normal | Collapse all |
| `x` | Normal | Cut |

## Telescope

| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-p>` | Normal | Open projects |
| `<leader><leader>f` | Normal | Find files |
| `<leader><leader>g` | Normal | Live grep |
| `<leader><leader>s` | Normal | Open command line |

## Options

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>oc` | Normal | Turn completion off |
| `<leader>oC` | Normal | Turn completion on |
| `<leader>ow` | Normal | Toggle wrap |
| `<leader>or` | Normal | Toggle relative numbers |
| `<leader>ol` | Normal | Toggle cursorline |
| `<leader>os` | Normal | Toggle spell check |
| `<leader>ot` | Normal | Toggle tabline |

## Session Management

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>Ss` | Normal | Save session |
| `<leader>Sr` | Normal | Restore session |
| `<leader>Sx` | Normal | Delete session |

## Search and Replace

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>rr` | Normal | Open replace |
| `<leader>rw` | Normal | Replace word (workspace) |
| `<leader>rf` | Normal | Replace word (buffer) |
| `<leader>rb` | Normal | Replace in buffer |

## Code Runner

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>Rb` | Normal | Build the project |
| `<leader>Rp` | Normal | Run python file |

## Find Commands

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>fB` | Normal | Checkout branch |
| `<leader>fc` | Normal | Choose colorscheme |
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Git files |
| `<leader>ftt` | Normal | Find text |
| `<leader>fta` | Normal | Find text (live grep args) |
| `<leader>fts` | Normal | Live grep word under cursor |
| `<leader>fss` | Normal | Find string in workspace |
| `<leader>fsb` | Normal | Grep only open files |
| `<leader>fh` | Normal | Help tags |
| `<leader>fH` | Normal | Highlights |
| `<leader>fi` | Normal | Incoming calls |
| `<leader>fo` | Normal | Outgoing calls |
| `<leader>fI` | Normal | Implementations |
| `<leader>fl` | Normal | Last search |
| `<leader>fM` | Normal | Man pages |
| `<leader>fr` | Normal | Recent files |
| `<leader>fp` | Normal | Frecency recent file |
| `<leader>fR` | Normal | Registers |
| `<leader>fk` | Normal | Keymaps |
| `<leader>fC` | Normal | Commands |

## Terminal Management

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>T1` | Normal | Terminal 1 |
| `<leader>T2` | Normal | Terminal 2 |
| `<leader>T3` | Normal | Terminal 3 |
| `<leader>T4` | Normal | Terminal 4 |
| `<leader>Tn` | Normal | Node terminal |
| `<leader>Tu` | Normal | NCDU terminal |
| `<leader>Tt` | Normal | Htop terminal |
| `<leader>Tm` | Normal | Make terminal |
| `<leader>Tf` | Normal | Float terminal |
| `<leader>Th` | Normal | Horizontal terminal |
| `<leader>Tv` | Normal | Vertical terminal |

## Additional Telescope Commands

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>tgS` | Normal | Git stash |
| `<leader>tC` | Normal | Command history |
| `<leader>tj` | Normal | Jumplist |
| `<leader>th` | Normal | Search history |
| `<leader>tb` | Normal | Telescope builtin |
| `<leader>tS` | Normal | Search buffer |
| `<leader>tp` | Normal | Switch project |

## Miscellaneous

| Keymap | Mode | Description |
|--------|------|-------------|
| `<C-z>` | Normal | Toggle Zen mode |
| `<s-t>` | Normal | Open TODO quickfix |
| `<m-t>` | Normal | Open TODO quickfix |
| `<m-q>` | Normal | Toggle quickfix window |
| `<C-l>` | Insert | Accept Copilot suggestion |
| `<C-S-h>` | Normal | Previous last used buffer |
| `<C-S-l>` | Normal | Next last used buffer |
| `<C-h>` | Normal | Previous buffer |
| `<C-l>` | Normal | Next buffer |
| `<leader>xt` | Normal | Toggle transparency |
| `<leader>b` | Normal | List buffers |
| `<leader>e` | Normal | Toggle file explorer |
| `<leader>w` | Normal | Write buffer |
| `<leader>h` | Normal | Clear search highlight |
| `<leader>q` | Normal | Smart quit |
| `<leader>ks` | Normal | Horizontal split |
| `<leader>kv` | Normal | Vertical split |

Note: Some keymaps might be commented out in the configuration. This documentation only includes active keymaps. 