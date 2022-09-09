# My NeoVim Config

This is a _heavily_ modified forked from [ChristianChiarulli's neovim](https://github.com/ChristianChiarulli/nvim). You can start-off with my config, and build something of your own from there, but ideally, you should always try writing your own. Using neovim, as [TJ DeVries](https://www.youtube.com/c/TJDeVries) says, usually becomes a PDE (Personal Development Environment). This config, just like any other config, is heavily personalized.

## Key mappings

- The leader key is `space`, and to open whichkey immediately, press: `Ctrl + Space`.
- To open all the available keymaps, press: "Ctrl + Space" -> "f" -> "k" (you should also see the options you are selecting)

## Changes from the fork

I wanted to create this as a standalone repo instead of a fork so that people can create issues if they are stuck. However, it will be unfair on the main author (ChristianChiarulli), as I also make sure to merge with his up-stream repo, whenever I find something that is new to me. So this repository will be a fork until I'm very happy with what I have, and once it diverges from upstream. Please follow the commits [here](https://github.com/ChristianChiarulli/nvim/compare/master...krshrimali:nvim:master) to follow the changes I've made to the original fork. The biggest of those should be: adding [my own plugin: AutoRunner](https://github.com/krshrimali/nvim-autorunner) 💙 . It's in a beta release, but feel free to test it out.

## Try out this config

Make sure to remove or move your current `nvim` directory

```sh
git clone git@github.com:krshrimali/nvim.git ~/.config/nvim
```

If you don't have neovim installed, there is a very useful script (comes from up-stream) that lets you install neovim: `./install_neovim.sh`.

Run `nvim` and wait for the plugins to be installed

**NOTE:** (You will notice treesitter pulling in a bunch of parsers the next time you open Neovim)

## Get healthy

Open `nvim` and enter the following:

```
:checkhealth
```

You'll probably notice you don't have support for copy/paste also that python and node haven't been setup

So let's fix that

First we'll fix copy/paste

- On mac `pbcopy` should be builtin

- On Ubuntu

  ```sh
  sudo apt install xsel
  ```

- On Arch Linux

  ```sh
  sudo pacman -S xsel
  ```

Next we need to install python support (node is optional)

- Neovim python support

  ```sh
  pip install pynvim
  ```

- Neovim node support

  ```sh
  npm i -g neovim
  ```

## Fonts

- [A nerd font](https://github.com/ryanoasis/nerd-fonts)

- [codicon](https://github.com/microsoft/vscode-codicons/raw/main/dist/codicon.ttf)
- [An emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoColorEmoji.ttf)

After moving fonts to `~/.local/share/fonts/`

Run: `$ fc-cache -f -v`

**NOTE:** (If you are seeing boxes without icons, try changing this line from `false` to `true`: [link](https://github.com/ChristianChiarulli/nvim/blob/ac41efa237caf3a498077df19a3f31ca4b35caf3/lua/user/icons.lua#L5))

## Install latest rust-analyzer binary

```sh
mkdir -p ~/.local/bin
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
chmod +x ~/.local/bin/rust-analyzer
```
