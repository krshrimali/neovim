# My NeoVim Config

This is a _heavily_ inspired (and for some files - directly copied) from [ChristianChiarulli's neovim](https://github.com/ChristianChiarulli/nvim). You can start-off with my config, and build something of your own from there, but ideally, you should always try writing your own. Using neovim, as [TJ DeVries](https://www.youtube.com/c/TJDeVries) says, usually becomes a PDE (Personal Development Environment). This config, just like any other config, is heavily personalized.

It's a current TODO for me to add instructions on how to set it up, but I'm not sure if it's needed. Please feel free to look at specific configs if you want to take inspiration, but I strongly suggest to start off with something from LunarVim/AstroVim/NvChad etc. and then build upon them to have something of your own. :) Sorry for being too honest, can't help it.

**Neovim Plugin List**

*Below is a categorized list of plugins used in this configuration.*

---

**LSP & Language Support**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| neoclide/coc.nvim                            | LSP client with completion |
| SmiteshP/nvim-navic                          | LSP context navigation     |
| hedyhli/outline.nvim                         | Symbols outline            |

*Includes auto-installed language servers: coc-pyright (Python), coc-tsserver (TypeScript/JavaScript), coc-rust-analyzer (Rust), coc-lua (Lua), coc-json (JSON), coc-snippets (Snippets)*

---

**Completion & Snippets**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| github/copilot.vim                           | Copilot AI                 |

*Completion is now handled by coc.nvim (see LSP section above)*

---

**Syntax Highlighting & Treesitter**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| nvim-treesitter/nvim-treesitter              | Treesitter                 |
| JoosepAlviste/nvim-ts-context-commentstring  | Treesitter commentstring   |
| lukas-reineke/indent-blankline.nvim          | Indent guides              |

---

**UI Enhancements**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| nvim-lualine/lualine.nvim                    | Status line                |
| xiyaowong/transparent.nvim                   | Transparent background     |
| rcarriga/nvim-notify                         | Notification UI            |
| stevearc/dressing.nvim                       | Improved UI                |
| ghillb/cybu.nvim                             | Buffer switcher            |
| tversteeg/registers.nvim                     | Registers popup            |
| nacro90/numb.nvim                            | Peek numbers               |
| fgheng/winbar.nvim                           | Winbar                     |
| folke/snacks.nvim                            | UI enhancements            |

---

**File Explorer & Navigation**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| nvim-tree/nvim-tree.lua                      | File explorer              |
| nvim-telescope/telescope.nvim                | Fuzzy finder               |
| nvim-telescope/telescope-live-grep-args.nvim | Telescope extension        |
| nvim-telescope/telescope-file-browser.nvim   | Telescope file browser     |
| nvim-telescope/telescope-frecency.nvim       | Telescope frecency         |
| jonarrien/telescope-cmdline.nvim             | Telescope cmdline          |
| krshrimali/context-pilot.nvim                | Context pilot              |

---

**Git Integration**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| NeogitOrg/neogit                             | Git UI                     |
| lewis6991/gitsigns.nvim                      | Git signs                  |
| f-person/git-blame.nvim                      | Git blame                  |

---

**Editing Utilities**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| RRethy/vim-illuminate                        | Highlight word under cursor|
| chrisgrieser/nvim-spider                     | Enhanced motions           |
| numToStr/Comment.nvim                        | Commenting                 |
| folke/todo-comments.nvim                     | TODO comments              |
| akinsho/toggleterm.nvim                      | Terminal integration       |
| nvim-pack/nvim-spectre                       | Search/replace             |
| kevinhwang91/nvim-bqf                        | Quickfix enhancements      |
| folke/which-key.nvim                         | Keybinding helper          |
| rmagatti/goto-preview                        | Preview definitions        |
| rmagatti/goto-preview (with logger.nvim)      | Preview definitions        |

---

**Project & Workspace**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| ahmedkhalf/project.nvim                      | Project management         |

---

**Diagnostics & Code Navigation**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| folke/trouble.nvim                           | Diagnostics UI             |

---

**Themes**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| decaycs/decay.nvim                           | Theme                      |
| lunarvim/darkplus.nvim                       | Theme                      |
| folke/tokyonight.nvim                        | Theme                      |
| uloco/bluloco.nvim                           | Theme                      |
| krshrimali/vim-moonfly-colors                | Theme                      |
| navarasu/onedark.nvim                        | Theme                      |
| ellisonleao/gruvbox.nvim                     | Theme                      |
| sainnhe/gruvbox-material                     | Theme                      |
| Shadorain/shadotheme                         | Theme                      |
| nyoom-engineering/oxocarbon.nvim             | Theme                      |
| projekt0n/github-nvim-theme                  | Theme                      |

---

**Utilities & Misc**

| Plugin                                      | Description                |
|----------------------------------------------|----------------------------|
| krshrimali/nvim-utils                        | Utilities                  |
| krshrimali/nvim-utils.nvim                   | Utilities (pytest runner)  |
| olimorris/codecompanion.nvim                 | AI assistant               |

---

## Key Mappings

**Leader Key:** `,` (comma)

### LSP & Code Navigation (coc.nvim)

| Key | Mode | Description |
|-----|------|-------------|
| `Tab` / `Shift-Tab` | Insert | Navigate completion menu |
| `Enter` | Insert | Accept completion |
| `Ctrl-Space` | Insert | Trigger completion |
| `gd` | Normal | Go to definition |
| `gy` | Normal | Go to type definition |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Go to references |
| `K` | Normal | Show documentation |
| `[g` / `]g` | Normal | Navigate diagnostics |
| `,rn` | Normal | Rename symbol |
| `,lf` | Normal/Visual | Format code |
| `,ld` | Normal | Show line diagnostics |
| `,a` | Normal/Visual | Code actions |
| `,ac` | Normal | Code actions (cursor) |
| `,as` | Normal | Source code actions |
| `,qf` | Normal | Quick fix |

### File Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `,ff` | Normal | Find files (respects .gitignore) |
| `,fg` | Normal | Git files |
| `,fw` | Normal | Live grep |
| `,fb` | Normal | Buffers |
| `,fr` | Normal | Recent files |

### Git Integration

| Key | Mode | Description |
|-----|------|-------------|
| `glb` | Normal | Git blame line |
| `,gY` | Normal/Visual | Git browse (open in browser) |

### Utility

| Key | Mode | Description |
|-----|------|-------------|
| `,q` | Normal | Smart quit |
| `,w` | Normal | Save file |
| `,e` | Normal | Toggle file explorer |

*For a complete list of keymaps, see `keymaps.md` and `keymaps_table.md`*

---
