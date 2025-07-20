# Neovim Keymaps Reference

This document contains all keymaps defined in the Neovim configuration organized by category.

## Core Keymaps (General)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `glb` | `<cmd>Gitsigns blame_line<cr>` | Git blame line | keymaps.lua |
| n | `+` | `<C-a>` | Increment number | keymaps.lua |
| n | `-` | `<C-x>` | Decrement number | keymaps.lua |
| n | `dw` | `vb"_d` | Delete word backwards | keymaps.lua |
| n | `<C-a>` | `gg<S-v>G` | Select all | keymaps.lua |
| n | `<C-w><left>` | `<C-w><` | Resize window left | keymaps.lua |
| n | `<C-w><right>` | `<C-w>>` | Resize window right | keymaps.lua |
| n | `<C-w><up>` | `<C-w>+` | Resize window up | keymaps.lua |
| n | `<C-w><down>` | `<C-w>-` | Resize window down | keymaps.lua |
| n | `<S-l>` | `:bnext<CR>` | Next buffer | keymaps.lua |
| n | `<S-h>` | `:bprevious<CR>` | Previous buffer | keymaps.lua |
| n | `<S-d>` | `<Esc>:m .+1<CR>` | Move line down | keymaps.lua |
| n | `<S-u>` | `<Esc>:m .-2<CR>` | Move line up | keymaps.lua |
| n | `<leader>d` | `"_d` | Delete to black hole register | keymaps.lua |
| n | `<leader>s` | `:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>` | Search and replace word under cursor | keymaps.lua |
| n | `<leader>Q` | `<cmd>bdelete!<CR>` | Force close buffer | keymaps.lua |
| n | `K` | Custom function | Show documentation | keymaps.lua |
| n | `<s-t>` | `<cmd>TodoQuickFix<cr>` | Todo quickfix | keymaps.lua |
| n | `<m-t>` | `<cmd>TodoQuickFix<cr>` | Todo quickfix (alt) | keymaps.lua |
| n | `<m-q>` | QuickFixToggle function | Toggle quickfix | keymaps.lua |
| i | `jk` | `<ESC>` | Alternative escape | keymaps.lua |
| i | `<C-l>` | `copilot#Accept("<CR>")` | Accept Copilot suggestion | keymaps.lua |
| v | `<` | `<gv` | Indent left and reselect | keymaps.lua |
| v | `>` | `>gv` | Indent right and reselect | keymaps.lua |
| v | `p` | `"_dP` | Paste without overwriting register | keymaps.lua |
| v | `F` | `:m '>+1<CR>gv=gv` | Move selection down | keymaps.lua |
| v | `U` | `:m '<-2<CR>gv=gv` | Move selection up | keymaps.lua |
| x | `<leader>d` | `"_d` | Delete to black hole register | keymaps.lua |
| x | `<leader>p` | `"_dP` | Paste without overwriting register | keymaps.lua |
| x | `<leader>lf` | `vim.lsp.buf.format` | Format selection | keymaps.lua |

## LSP Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<F11>` | `<cmd>lua vim.lsp.buf.references()<CR>` | LSP references | keymaps.lua |
| n | `<F12>` | `<cmd>lua vim.lsp.buf.definition()<CR>` | LSP definition | keymaps.lua |
| n | `gd` | `<cmd>lua vim.lsp.buf.definition()<CR>` | Go to definition | keymaps.lua |
| n | `gR` | `<cmd>lua vim.lsp.buf.references()<CR>` | Go to references | keymaps.lua |
| n | `gi` | `<cmd>lua vim.lsp.buf.implementation()<CR>` | Go to implementation | keymaps.lua |
| n | `go` | `<cmd>lua vim.lsp.buf.outgoing_calls()<CR>` | LSP outgoing calls | keymaps.lua |
| n | `<C-s>` | `<cmd>lua vim.lsp.buf.document_symbol()<cr>` | Document symbols | keymaps.lua |
| n | `gr` | `<cmd>lua vim.lsp.buf.references()<CR>` | LSP references | keymaps.lua |

## Spider Motion Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n,o,x | `w` | `require("spider").motion "w"` | Spider word motion | keymaps.lua |
| n,o,x | `e` | `require("spider").motion "e"` | Spider end motion | keymaps.lua |
| n,o,x | `b` | `require("spider").motion "b"` | Spider back motion | keymaps.lua |
| n,o,x | `ge` | `require("spider").motion "ge"` | Spider ge motion | keymaps.lua |

## Goto Preview Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>gpd` | Go to preview definition | Go to preview definition | keymaps.lua |
| n | `<leader>gpi` | Go to preview implementation | Go to preview implementation | keymaps.lua |
| n | `<leader>gpD` | Go to preview declaration | Go to preview declaration | keymaps.lua |
| n | `<leader>gP` | Close all preview windows | Close all preview windows | keymaps.lua |
| n | `<leader>gpr` | Go to preview references | Go to preview references | keymaps.lua |

## Git Browse Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n,x | `<leader>gy` | Copy git browse URL | Copy git browse URL to clipboard | keymaps.lua |

## Telescope & File Navigation

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<C-p>` | `<cmd>Telescope projects<cr>` | Telescope projects | keymaps.lua |
| n | `<C-z>` | `<cmd>ZenMode<cr>` | Toggle ZenMode | keymaps.lua |
| n | `-` | `<CMD>Oil<CR>` | Open Oil file explorer | keymaps.lua |
| n | `<leader><leader>f` | Custom find_files function | Find files | keymaps.lua |
| n | `<leader><leader>g` | Custom live_grep function | Live grep | keymaps.lua |
| n | `<leader><leader>s` | `:silent Telescope cmdline<CR>` | Telescope command line | keymaps.lua |

## Which-Key Mappings

### Core Actions

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>b` | `<cmd>Telescope buffers<cr>` | Buffers | whichkey.lua |
| n | `<leader>e` | `<cmd>NvimTreeToggle<cr>` | Explorer | whichkey.lua |
| n | `<leader>w` | `<cmd>w<CR>` | Write | whichkey.lua |
| n | `<leader>h` | `<cmd>nohlsearch<CR>` | No highlight | whichkey.lua |
| n | `<leader>q` | `<cmd>lua require('user.functions').smart_quit()<CR>` | Quit | whichkey.lua |

### Options (`<leader>o`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>oc` | `<cmd>lua vim.g.cmp_active=false<cr>` | Completion off | whichkey.lua |
| n | `<leader>oC` | `<cmd>lua vim.g.cmp_active=true<cr>` | Completion on | whichkey.lua |
| n | `<leader>ow` | Toggle wrap option | Toggle wrap | whichkey.lua |
| n | `<leader>or` | Toggle relative numbers | Toggle relative numbers | whichkey.lua |
| n | `<leader>ol` | Toggle cursor line | Toggle cursor line | whichkey.lua |
| n | `<leader>os` | Toggle spell check | Toggle spell check | whichkey.lua |
| n | `<leader>ot` | Toggle tabline | Toggle tabline | whichkey.lua |

### Split (`<leader>k`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>ks` | `<cmd>split<cr>` | Horizontal split | whichkey.lua |
| n | `<leader>kv` | `<cmd>vsplit<cr>` | Vertical split | whichkey.lua |

### Session (`<leader>S`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>Ss` | `<cmd>SessionSave<cr>` | Save session | whichkey.lua |
| n | `<leader>Sr` | `<cmd>SessionRestore<cr>` | Restore session | whichkey.lua |
| n | `<leader>Sx` | `<cmd>SessionDelete<cr>` | Delete session | whichkey.lua |

### Replace (`<leader>r`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>rr` | `<cmd>lua require('spectre').open()<cr>` | Replace | whichkey.lua |
| n | `<leader>rw` | Replace word (workspace) | Replace word workspace | whichkey.lua |
| n | `<leader>rf` | Replace word (buffer) | Replace word buffer | whichkey.lua |
| n | `<leader>rb` | Replace buffer | Replace buffer | whichkey.lua |

### Code Runner (`<leader>R`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>Rb` | `:TermExec cmd=./.buildme.sh<CR>` | Build project | whichkey.lua |
| n | `<leader>Rp` | Run python file | Run python file | whichkey.lua |

### Find/Telescope (`<leader>f`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>fB` | `<cmd>Telescope git_branches<cr>` | Checkout branch | whichkey.lua |
| n | `<leader>fc` | `<cmd>Telescope colorscheme<cr>` | Colorscheme | whichkey.lua |
| n | `<leader>ff` | `<cmd>Telescope find_files<cr>` | Find files | whichkey.lua |
| n | `<leader>fg` | `<cmd>Telescope git_files<cr>` | Git files | whichkey.lua |
| n | `<leader>ftt` | `<cmd>Telescope live_grep<cr>` | Find text | whichkey.lua |
| n | `<leader>fta` | `<cmd>Telescope live_grep_args<cr>` | Live grep args | whichkey.lua |
| n | `<leader>fts` | Live grep with word under cursor | Live grep word | whichkey.lua |
| n | `<leader>fss` | Find string in workspace | Find string workspace | whichkey.lua |
| n | `<leader>fsb` | Grep only open files | Grep open files | whichkey.lua |
| n | `<leader>fh` | `<cmd>Telescope help_tags<cr>` | Help | whichkey.lua |
| n | `<leader>fH` | `<cmd>Telescope highlights<cr>` | Highlights | whichkey.lua |
| n | `<leader>fi` | `<cmd>Telescope lsp_incoming_calls<cr>` | Incoming calls | whichkey.lua |
| n | `<leader>fo` | `<cmd>Telescope lsp_outgoing_calls<cr>` | Outgoing calls | whichkey.lua |
| n | `<leader>fI` | `<cmd>Telescope lsp_implementations<cr>` | Implementations | whichkey.lua |
| n | `<leader>fl` | `<cmd>Telescope resume<cr>` | Last search | whichkey.lua |
| n | `<leader>fM` | `<cmd>Telescope man_pages<cr>` | Man pages | whichkey.lua |
| n | `<leader>fr` | `<cmd>Telescope oldfiles<cr>` | Recent files | whichkey.lua |
| n | `<leader>fp` | `<cmd>Telescope frecency workspace=CWD<cr>` | Frecency | whichkey.lua |
| n | `<leader>fR` | `<cmd>Telescope registers<cr>` | Registers | whichkey.lua |
| n | `<leader>fk` | `<cmd>Telescope keymaps<cr>` | Keymaps | whichkey.lua |
| n | `<leader>fC` | `<cmd>Telescope commands<cr>` | Commands | whichkey.lua |

### Git (`<leader>g`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>gg` | `<cmd>lua require ('user.terminal').lazygit_toggle()<cr>` | Lazygit | whichkey.lua |
| n | `<leader>gj` | `<cmd>lua require 'gitsigns'.next_hunk()<cr>` | Next hunk | whichkey.lua |
| n | `<leader>gk` | `<cmd>lua require 'gitsigns'.prev_hunk()<cr>` | Previous hunk | whichkey.lua |
| n | `<leader>gll` | `<cmd>GitBlameToggle<cr>` | Blame virtual text | whichkey.lua |
| n | `<leader>glf` | `<cmd>Git blame<cr>` | Blame column | whichkey.lua |
| n | `<leader>glg` | `<cmd>Gitsigns blame_line<cr>` | Blame line preview | whichkey.lua |
| n | `<leader>gp` | `<cmd>lua require 'gitsigns'.preview_hunk()<cr>` | Preview hunk | whichkey.lua |
| n | `<leader>gr` | `<cmd>lua require 'gitsigns'.reset_hunk()<cr>` | Reset hunk | whichkey.lua |
| n | `<leader>gR` | `<cmd>lua require 'gitsigns'.reset_buffer()<cr>` | Reset buffer | whichkey.lua |
| n | `<leader>gs` | `<cmd>lua require 'gitsigns'.stage_hunk()<cr>` | Stage hunk | whichkey.lua |
| n | `<leader>gu` | `<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>` | Undo stage hunk | whichkey.lua |
| n | `<leader>go` | `<cmd>Telescope git_status<cr>` | Open changed file | whichkey.lua |
| n | `<leader>gd` | `<cmd>Gitsigns diffthis HEAD<cr>` | Diff | whichkey.lua |

### GitBlame (`<leader>G`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>Gl` | `<cmd>GitBlameToggle<cr>` | Blame toggle | whichkey.lua |
| n | `<leader>Gc` | `<cmd>GitBlameCopySHA<cr>` | Copy SHA URL | whichkey.lua |
| n | `<leader>Go` | `<cmd>GitBlameOpenCommitURL<cr>` | Open commit URL | whichkey.lua |

### LSP (`<leader>l`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>lA` | `<cmd>lua vim.lsp.codelens.run()<cr>` | CodeLens action | whichkey.lua |
| n | `<leader>la` | `<cmd>lua vim.lsp.buf.code_action()<cr>` | Code action | whichkey.lua |
| n | `<leader>ld` | Document diagnostics | Document diagnostics | whichkey.lua |
| n | `<leader>lw` | Workspace diagnostics | Workspace diagnostics | whichkey.lua |
| n | `<leader>lf` | `<cmd>lua vim.lsp.buf.format({ async = true })<cr>` | Format | whichkey.lua |
| n | `<leader>lF` | `<cmd>LspToggleAutoFormat<cr>` | Toggle autoformat | whichkey.lua |
| n | `<leader>li` | `<cmd>MasonLog<cr>` | Info | whichkey.lua |
| n | `<leader>lH` | `<cmd>IlluminateToggle<cr>` | Toggle doc highlight | whichkey.lua |
| n | `<leader>lI` | `<cmd>Mason<cr>` | Installer info | whichkey.lua |
| n | `<leader>lj` | Next diagnostic | Next diagnostic | whichkey.lua |
| n | `<leader>lk` | Previous diagnostic | Previous diagnostic | whichkey.lua |
| n | `<leader>lev` | `<cmd>lua require('lsp_lines').toggle()<cr>` | Virtual lines | whichkey.lua |
| n | `<leader>leV` | Toggle virtual text | Toggle virtual text | whichkey.lua |
| n | `<leader>lo` | `<cmd>Outline<cr>` | Outline toggle | whichkey.lua |
| n | `<leader>lq` | Quickfix diagnostics | Quickfix diagnostics | whichkey.lua |
| n | `<leader>lQ` | Quickfix telescope | Quickfix telescope | whichkey.lua |
| n | `<leader>lR` | `<cmd>lua vim.lsp.buf.rename()<cr>` | Rename | whichkey.lua |
| n | `<leader>lr` | `<cmd>Trouble lsp_references<cr>` | References | whichkey.lua |
| n | `<leader>ls` | `<cmd>Telescope lsp_document_symbols<cr>` | Document symbols | whichkey.lua |
| n | `<leader>lS` | `<cmd>Telescope lsp_dynamic_workspace_symbols<cr>` | Workspace symbols | whichkey.lua |
| n | `<leader>lgg` | Goto preview definition | Goto preview definition | whichkey.lua |
| n | `<leader>lgt` | Goto preview type definition | Goto preview type definition | whichkey.lua |
| n | `<leader>lgi` | Goto preview implementation | Goto preview implementation | whichkey.lua |
| n | `<leader>lgr` | Goto preview references | Goto preview references | whichkey.lua |
| n | `<leader>lgc` | Close all preview windows | Close all preview windows | whichkey.lua |
| n | `<leader>lgv` | Vertical split definition | Vertical split definition | whichkey.lua |
| n | `<leader>lgh` | Horizontal split definition | Horizontal split definition | whichkey.lua |
| n | `<leader>lt` | Toggle diagnostics | Toggle diagnostics | whichkey.lua |
| n | `<leader>lu` | `<cmd>LuaSnipUnlinkCurrent<cr>` | Unlink snippet | whichkey.lua |
| n | `<leader>ldu` | Diagnostics (listed buffers) | Diagnostics listed buffers | whichkey.lua |

### Terminal (`<leader>T`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>T1` | `:1ToggleTerm<cr>` | Terminal 1 | whichkey.lua |
| n | `<leader>T2` | `:2ToggleTerm<cr>` | Terminal 2 | whichkey.lua |
| n | `<leader>T3` | `:3ToggleTerm<cr>` | Terminal 3 | whichkey.lua |
| n | `<leader>T4` | `:4ToggleTerm<cr>` | Terminal 4 | whichkey.lua |
| n | `<leader>Tn` | Node terminal | Node terminal | whichkey.lua |
| n | `<leader>Tu` | NCDU terminal | NCDU terminal | whichkey.lua |
| n | `<leader>Tt` | Htop terminal | Htop terminal | whichkey.lua |
| n | `<leader>Tm` | Make terminal | Make terminal | whichkey.lua |
| n | `<leader>Tf` | Float terminal | Float terminal | whichkey.lua |
| n | `<leader>Th` | Horizontal terminal | Horizontal terminal | whichkey.lua |
| n | `<leader>Tv` | Vertical terminal | Vertical terminal | whichkey.lua |

### Telescope Extended (`<leader>t`)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>tgS` | `<cmd>Telescope git_stash<cr>` | Git stash | whichkey.lua |
| n | `<leader>tC` | `<cmd>Telescope command_history<cr>` | Command history | whichkey.lua |
| n | `<leader>tj` | `<cmd>Telescope jumplist<cr>` | Jumplist | whichkey.lua |
| n | `<leader>th` | `<cmd>Telescope search_history<cr>` | Search history | whichkey.lua |
| n | `<leader>tb` | `<cmd>Telescope builtin<cr>` | Builtin | whichkey.lua |
| n | `<leader>tS` | `<cmd>Telescope current_buffer_fuzzy_find<cr>` | Search buffer | whichkey.lua |
| n | `<leader>tp` | `<cmd>Telescope projects<cr>` | Switch project | whichkey.lua |

### Miscellaneous

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>xt` | `<cmd>TransparentToggle<cr>` | Toggle transparency | whichkey.lua |

## ToggleTerm Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| t | `<esc>` | `<C-\><C-n>` | Exit terminal mode | toggleterm.lua |
| t | `jk` | `<C-\><C-n>` | Exit terminal mode | toggleterm.lua |
| t | `<C-h>` | `<C-\><C-n><C-W>h` | Navigate left | toggleterm.lua |
| t | `<C-j>` | `<C-\><C-n><C-W>j` | Navigate down | toggleterm.lua |
| t | `<C-k>` | `<C-\><C-n><C-W>k` | Navigate up | toggleterm.lua |
| t | `<C-l>` | `<C-\><C-n><C-W>l` | Navigate right | toggleterm.lua |
| n,i | `<m-1>` | Float terminal toggle | Float terminal | toggleterm.lua |
| n,i | `<m-2>` | Vertical terminal toggle | Vertical terminal | toggleterm.lua |
| n,i | `<m-3>` | Horizontal terminal toggle | Horizontal terminal | toggleterm.lua |

## NvimTree Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<C-]>` | Change root to node | Change root | nvim-tree.lua |
| n | `<C-e>` | Open in place | Open in place | nvim-tree.lua |
| n | `<C-k>` | Show info popup | Show info | nvim-tree.lua |
| n | `<C-r>` | Rename (omit filename) | Rename | nvim-tree.lua |
| n | `<C-t>` | Open in new tab | Open tab | nvim-tree.lua |
| n | `<C-v>` | Vertical split | Vertical split | nvim-tree.lua |
| n | `<C-\>` | Vertical split | Vertical split | nvim-tree.lua |
| n | `<C-x>` | Horizontal split | Horizontal split | nvim-tree.lua |
| n | `<BS>` | Close directory | Close directory | nvim-tree.lua |
| n | `<CR>` | Open | Open | nvim-tree.lua |
| n | `<Tab>` | Preview | Preview | nvim-tree.lua |
| n | `>` | Next sibling | Next sibling | nvim-tree.lua |
| n | `<` | Previous sibling | Previous sibling | nvim-tree.lua |
| n | `.` | Run command | Run command | nvim-tree.lua |
| n | `-` | Up to parent | Up to parent | nvim-tree.lua |
| n | `a` | Create | Create | nvim-tree.lua |
| n | `bmv` | Move bookmarked | Move bookmarked | nvim-tree.lua |
| n | `B` | Toggle no buffer filter | Toggle no buffer filter | nvim-tree.lua |
| n | `c` | Copy | Copy | nvim-tree.lua |
| n | `C` | Toggle git clean filter | Toggle git clean filter | nvim-tree.lua |
| n | `[c` | Previous git | Previous git | nvim-tree.lua |
| n | `]c` | Next git | Next git | nvim-tree.lua |
| n | `d` | Delete | Delete | nvim-tree.lua |
| n | `D` | Trash | Trash | nvim-tree.lua |
| n | `E` | Expand all | Expand all | nvim-tree.lua |
| n | `e` | Rename basename | Rename basename | nvim-tree.lua |
| n | `]e` | Next diagnostic | Next diagnostic | nvim-tree.lua |
| n | `[e` | Previous diagnostic | Previous diagnostic | nvim-tree.lua |
| n | `F` | Clear filter | Clear filter | nvim-tree.lua |
| n | `f` | Filter | Filter | nvim-tree.lua |
| n | `g?` | Help | Help | nvim-tree.lua |
| n | `gy` | Copy absolute path | Copy absolute path | nvim-tree.lua |
| n | `H` | Toggle hidden filter | Toggle hidden filter | nvim-tree.lua |
| n | `I` | Toggle gitignore filter | Toggle gitignore filter | nvim-tree.lua |
| n | `J` | Last sibling | Last sibling | nvim-tree.lua |
| n | `K` | First sibling | First sibling | nvim-tree.lua |
| n | `m` | Toggle bookmark | Toggle bookmark | nvim-tree.lua |
| n | `o` | Open | Open | nvim-tree.lua |
| n | `O` | Open no window picker | Open no window picker | nvim-tree.lua |
| n | `p` | Paste | Paste | nvim-tree.lua |
| n | `P` | Parent directory | Parent directory | nvim-tree.lua |
| n | `q` | Close | Close | nvim-tree.lua |
| n | `r` | Rename | Rename | nvim-tree.lua |
| n | `R` | Refresh | Refresh | nvim-tree.lua |
| n | `s` | Run system | Run system | nvim-tree.lua |
| n | `S` | Search | Search | nvim-tree.lua |
| n | `U` | Toggle custom filter | Toggle custom filter | nvim-tree.lua |
| n | `W` | Collapse | Collapse | nvim-tree.lua |
| n | `x` | Cut | Cut | nvim-tree.lua |
| n | `y` | Copy name | Copy name | nvim-tree.lua |
| n | `Y` | Copy relative path | Copy relative path | nvim-tree.lua |
| n | `l` | Open | Open (custom) | nvim-tree.lua |
| n | `h` | Close directory | Close directory (custom) | nvim-tree.lua |
| n | `v` | Vertical split | Vertical split (custom) | nvim-tree.lua |
| n | `\` | Vertical split | Vertical split (custom) | nvim-tree.lua |

## Cybu Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<C-S-h>` | Previous last used buffer | Previous last used buffer | cybu.lua |
| n | `<C-S-l>` | Next last used buffer | Next last used buffer | cybu.lua |
| n | `<C-h>` | Previous buffer | Previous buffer | cybu.lua |
| n | `<C-l>` | Next buffer | Next buffer | cybu.lua |

## Surround Keymaps

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>'` | Surround with single quotes | Surround single quotes | surround.lua |
| n | `<leader>"` | Surround with double quotes | Surround double quotes | surround.lua |

## Language-Specific Keymaps

### Go (ftplugin/go.lua)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>Ci` | Install Go dependencies | Install Go dependencies | ftplugin/go.lua |
| n | `<leader>Cf` | Go mod tidy | Go mod tidy | ftplugin/go.lua |
| n | `<leader>Ca` | Add test | Add test | ftplugin/go.lua |
| n | `<leader>CA` | Add all tests | Add all tests | ftplugin/go.lua |
| n | `<leader>Ce` | Add exported tests | Add exported tests | ftplugin/go.lua |
| n | `<leader>Cg` | Go generate | Go generate | ftplugin/go.lua |
| n | `<leader>CG` | Go generate file | Go generate file | ftplugin/go.lua |
| n | `<leader>Cc` | Generate comment | Generate comment | ftplugin/go.lua |
| n | `<leader>Ct` | Debug test | Debug test | ftplugin/go.lua |

### Rust (ftplugin/rust.lua)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<m-d>` | `<cmd>RustOpenExternalDocs<Cr>` | Open external docs | ftplugin/rust.lua |

### TOML/Cargo (ftplugin/toml.lua)

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>Lt` | Toggle crates hints | Toggle crates hints | ftplugin/toml.lua |
| n | `<leader>Lu` | Update crate | Update crate | ftplugin/toml.lua |
| n | `<leader>LU` | Upgrade crate | Upgrade crate | ftplugin/toml.lua |
| n | `<leader>La` | Update all crates | Update all crates | ftplugin/toml.lua |
| n | `<leader>LA` | Upgrade all crates | Upgrade all crates | ftplugin/toml.lua |
| n | `<leader>Lh` | Open homepage | Open homepage | ftplugin/toml.lua |
| n | `<leader>Lr` | Open repository | Open repository | ftplugin/toml.lua |
| n | `<leader>Ld` | Open documentation | Open documentation | ftplugin/toml.lua |
| n | `<leader>Lc` | Open crates.io | Open crates.io | ftplugin/toml.lua |
| n | `<leader>Li` | Show info popup | Show info popup | ftplugin/toml.lua |
| n | `<leader>Lv` | Show versions popup | Show versions popup | ftplugin/toml.lua |
| n | `<leader>Lf` | Show features popup | Show features popup | ftplugin/toml.lua |
| n | `<leader>LD` | Show dependencies popup | Show dependencies popup | ftplugin/toml.lua |

## Plugin Keys from Lazy.nvim

### Trouble Plugin

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>xx` | `<cmd>Trouble diagnostics toggle<cr>` | Diagnostics | lazy plugins |
| n | `<leader>xX` | `<cmd>Trouble diagnostics toggle filter.buf=0<cr>` | Buffer diagnostics | lazy plugins |
| n | `<leader>cs` | `<cmd>Trouble symbols toggle focus=false<cr>` | Symbols | lazy plugins |
| n | `<leader>cl` | `<cmd>Trouble lsp toggle focus=false win.position=right<cr>` | LSP definitions/references | lazy plugins |
| n | `<leader>xL` | `<cmd>Trouble loclist toggle<cr>` | Location list | lazy plugins |
| n | `<leader>xQ` | `<cmd>Trouble qflist toggle<cr>` | Quickfix list | lazy plugins |

### Snacks Dashboard

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `f` | Find file | Find file | lazy plugins |
| n | `n` | New file | New file | lazy plugins |
| n | `g` | Find text | Find text | lazy plugins |
| n | `r` | Recent files | Recent files | lazy plugins |
| n | `c` | Config | Config | lazy plugins |
| n | `s` | Restore session | Restore session | lazy plugins |
| n | `l` | Lazy | Lazy | lazy plugins |
| n | `q` | Quit | Quit | lazy plugins |

### Claude Code Plugin

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n | `<leader>ac` | `<cmd>ClaudeCode<cr>` | Toggle Claude | lazy plugins |
| n | `<leader>af` | `<cmd>ClaudeCodeFocus<cr>` | Focus Claude | lazy plugins |
| n | `<leader>ar` | `<cmd>ClaudeCode --resume<cr>` | Resume Claude | lazy plugins |
| n | `<leader>aC` | `<cmd>ClaudeCode --continue<cr>` | Continue Claude | lazy plugins |
| n | `<leader>ab` | `<cmd>ClaudeCodeAdd %<cr>` | Add current buffer | lazy plugins |
| v | `<leader>as` | `<cmd>ClaudeCodeSend<cr>` | Send to Claude | lazy plugins |
| n | `<leader>as` | `<cmd>ClaudeCodeTreeAdd<cr>` | Add file | lazy plugins |

### Git Browse

| Mode | Key | Action | Description | File |
|------|-----|--------|-------------|------|
| n,v | `<leader>gY` | Git browse | Git browse | lazy plugins |

## Duplicate Keymaps

The following keymaps have been defined multiple times with different actions:

| Key | Mode | First Definition | Second Definition | Conflict Type |
|-----|------|-----------------|------------------|---------------|
| `gr` | n | `<cmd>lua vim.lsp.buf.references()<CR>` (keymaps.lua) | `<cmd>lua vim.lsp.buf.references()<CR>` (keymaps.lua) | Same action, different locations |
| `<leader>lo` | n | `<cmd>Outline<cr>` (whichkey.lua) | `<cmd>Outline<CR>` (lazy plugins) | Same action, different case |
| `<leader>gY` | n,v | Git browse (lazy plugins) | - | Multiple mode definitions |
| `<C-h>` | n | `<C-\><C-n><C-W>h` (toggleterm.lua) | Previous buffer (cybu.lua) | Different actions |
| `<C-l>` | n | `<C-\><C-n><C-W>l` (toggleterm.lua) | Next buffer (cybu.lua) | Different actions |
| `<C-l>` | i | `copilot#Accept("<CR>")` (keymaps.lua) | - | Insert mode specific |
| `-` | n | `<C-x>` (keymaps.lua) | `<CMD>Oil<CR>` (keymaps.lua) | Different actions |
| `<leader>as` | n,v | Different actions | Add file vs Send to Claude | Mode-specific |

**Note on Conflicts:**
- Some conflicts are expected (mode-specific or context-specific)
- `<C-h>` and `<C-l>` have different meanings in terminal vs normal mode
- The `-` key conflict between decrement and Oil should be resolved
- Most other duplicates are harmless (same action, different definitions)
