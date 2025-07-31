# Fish shell configuration
# Enable vi mode for vim-like editing
fish_vi_key_bindings

# Set vi mode indicator
function fish_mode_prompt
    switch $fish_bind_mode
        case default
            echo -n '[N] '
        case insert
            echo -n '[I] '
        case visual
            echo -n '[V] '
        case replace_one
            echo -n '[R] '
        case replace
            echo -n '[R] '
    end
end

# Custom key bindings for vi mode
function fish_user_key_bindings
    # Enable vi key bindings
    fish_vi_key_bindings
    
    # Bind jk to escape to normal mode (common vim pattern)
    # Use a more reliable binding that works in terminal environments
    bind -M insert jk 'set fish_bind_mode default; commandline -f repaint'
    
    # Bind Escape to enter normal mode
    bind -M insert \e 'set fish_bind_mode default; commandline -f repaint'
    
    # Additional vi-mode bindings
    bind -M default \cc 'set fish_bind_mode insert; commandline -f repaint'
    bind -M default i 'set fish_bind_mode insert; commandline -f repaint'
    bind -M default a 'set fish_bind_mode insert; commandline -f forward-char repaint'
    bind -M default A 'set fish_bind_mode insert; commandline -f end-of-line repaint'
    bind -M default o 'set fish_bind_mode insert; commandline -f end-of-line repaint; commandline -i \n'
    bind -M default O 'set fish_bind_mode insert; commandline -f beginning-of-line repaint; commandline -i \n; commandline -f up-line'
    
    # Ensure proper terminal handling
    bind -M insert \r execute
    bind -M default \r execute
end

# Improve command completion
set -g fish_complete_path $fish_complete_path ~/.config/fish/completions

# Set some useful environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# Add some useful aliases
alias ll 'ls -la'
alias la 'ls -la'
alias l 'ls -l'
alias .. 'cd ..'
alias ... 'cd ../..'
alias grep 'grep --color=auto'

# Git aliases
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git log --oneline'

# Enable syntax highlighting and autosuggestions if available
if test -e /usr/share/fish/vendor_completions.d
    set -g fish_complete_path $fish_complete_path /usr/share/fish/vendor_completions.d
end

# Welcome message
function fish_greeting
    echo "Fish shell with vi mode enabled"
    echo "Use 'jk' or 'Esc' to enter normal mode"
end