#!/bin/bash
# Neovim Virtual Environment Integration
# Source this file in your ~/.bashrc or ~/.zshrc to enable enhanced virtualenv integration

# Configuration
NVIM_VENV_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nvim/nvim_virtualenv_state"
NVIM_VENV_NOTIFY_ENABLED=1

# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$NVIM_VENV_STATE_FILE")"

# Function to notify Neovim about virtualenv changes
nvim_notify_venv_change() {
    if [[ $NVIM_VENV_NOTIFY_ENABLED -eq 1 ]]; then
        # Update state file for Neovim to detect
        echo "${VIRTUAL_ENV:-}" > "$NVIM_VENV_STATE_FILE"
        
        # If we're inside a Neovim terminal, we can use nvim --remote-send
        if [[ -n "$NVIM" ]] && command -v nvr >/dev/null 2>&1; then
            # Use neovim-remote if available
            nvr --remote-send '<Esc>:VirtualEnvSync<CR>' 2>/dev/null || true
        fi
    fi
}

# Override the activate function to hook into virtualenv activation
original_activate_virtualenv() {
    if [[ -n "$1" && -f "$1/bin/activate" ]]; then
        source "$1/bin/activate"
        nvim_notify_venv_change
        echo "Virtual environment activated: $1"
        echo "Neovim will be notified of this change."
    else
        echo "Usage: activate_venv <path_to_virtualenv>"
        echo "Example: activate_venv ./venv"
    fi
}

# Enhanced source command for virtualenv activation
activate_venv() {
    original_activate_virtualenv "$@"
}

# Hook into deactivate if it exists
if declare -f deactivate >/dev/null 2>&1; then
    # Save original deactivate function
    eval "original_$(declare -f deactivate)"
    
    deactivate() {
        original_deactivate "$@"
        nvim_notify_venv_change
        echo "Virtual environment deactivated."
        echo "Neovim will be notified of this change."
    }
fi

# Function to create and activate a new virtualenv
create_venv() {
    local venv_name="${1:-venv}"
    local python_version="${2:-python3}"
    
    if [[ -d "$venv_name" ]]; then
        echo "Virtual environment '$venv_name' already exists."
        read -p "Activate it? [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            activate_venv "$venv_name"
        fi
        return
    fi
    
    echo "Creating virtual environment '$venv_name' with $python_version..."
    if command -v virtualenv >/dev/null 2>&1; then
        virtualenv -p "$python_version" "$venv_name"
    else
        "$python_version" -m venv "$venv_name"
    fi
    
    if [[ $? -eq 0 ]]; then
        echo "Virtual environment created successfully."
        read -p "Activate it now? [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            activate_venv "$venv_name"
        fi
    else
        echo "Failed to create virtual environment."
    fi
}

# Function to list available virtual environments
list_venvs() {
    echo "Available virtual environments:"
    echo
    
    # Common locations
    local search_paths=(
        "$HOME/.virtualenvs"
        "$HOME/.pyenv/versions"
        "$HOME/venv"
        "$HOME/virtualenvs"
        "./venv"
        "./.venv"
        "./env"
        "./.env"
    )
    
    local found=0
    for path in "${search_paths[@]}"; do
        if [[ -d "$path" ]]; then
            for venv in "$path"/*; do
                if [[ -d "$venv" && (-f "$venv/bin/activate" || -f "$venv/pyvenv.cfg") ]]; then
                    local name=$(basename "$venv")
                    local full_path=$(realpath "$venv" 2>/dev/null || echo "$venv")
                    echo "  $name -> $full_path"
                    found=1
                fi
            done
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "  No virtual environments found in common locations."
        echo "  Use 'create_venv <name>' to create a new one."
    fi
    
    echo
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Currently active: $(basename "$VIRTUAL_ENV") -> $VIRTUAL_ENV"
    else
        echo "No virtual environment currently active."
    fi
}

# Function to quickly switch between virtual environments
switch_venv() {
    if [[ -z "$1" ]]; then
        echo "Available virtual environments:"
        list_venvs
        echo
        read -p "Enter virtual environment name to activate: " venv_name
        if [[ -z "$venv_name" ]]; then
            echo "No virtual environment specified."
            return 1
        fi
    else
        local venv_name="$1"
    fi
    
    # Try to find the virtualenv
    local search_paths=(
        "$HOME/.virtualenvs/$venv_name"
        "$HOME/.pyenv/versions/$venv_name"
        "$HOME/venv/$venv_name"
        "$HOME/virtualenvs/$venv_name"
        "./$venv_name"
        "./venv"
        "./.venv"
        "./env"
        "./.env"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path/bin/activate" ]]; then
            if [[ -n "$VIRTUAL_ENV" ]]; then
                deactivate
            fi
            activate_venv "$path"
            return 0
        fi
    done
    
    echo "Virtual environment '$venv_name' not found."
    echo "Use 'list_venvs' to see available environments."
    return 1
}

# Function to toggle virtualenv notification
toggle_nvim_venv_notify() {
    if [[ $NVIM_VENV_NOTIFY_ENABLED -eq 1 ]]; then
        NVIM_VENV_NOTIFY_ENABLED=0
        echo "Neovim virtualenv notifications disabled."
    else
        NVIM_VENV_NOTIFY_ENABLED=1
        echo "Neovim virtualenv notifications enabled."
    fi
}

# Auto-detect and suggest virtualenv on cd
auto_venv_detect() {
    # Only run in interactive shells
    [[ $- == *i* ]] || return
    
    # Check for common virtualenv files in current directory
    local venv_indicators=("venv" ".venv" "env" ".env" "requirements.txt" "pyproject.toml" "setup.py")
    local found_indicator=""
    
    for indicator in "${venv_indicators[@]}"; do
        if [[ -e "$indicator" ]]; then
            found_indicator="$indicator"
            break
        fi
    done
    
    if [[ -n "$found_indicator" ]]; then
        # Look for virtual environment directories
        local venv_dirs=("venv" ".venv" "env" ".env")
        for venv_dir in "${venv_dirs[@]}"; do
            if [[ -d "$venv_dir" && -f "$venv_dir/bin/activate" ]]; then
                if [[ -z "$VIRTUAL_ENV" || "$VIRTUAL_ENV" != "$(realpath "$venv_dir")" ]]; then
                    echo "🐍 Python project detected with virtual environment: $venv_dir"
                    read -p "Activate virtual environment? [Y/n]: " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                        activate_venv "$venv_dir"
                    fi
                fi
                return
            fi
        done
        
        # If we found Python project indicators but no venv, suggest creating one
        if [[ -z "$VIRTUAL_ENV" ]]; then
            echo "🐍 Python project detected but no virtual environment found."
            read -p "Create virtual environment? [Y/n]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                create_venv
            fi
        fi
    fi
}

# Hook into cd command for auto-detection
if [[ "$BASH_VERSION" ]]; then
    # Bash
    original_cd=$(declare -f cd 2>/dev/null || echo "cd() { builtin cd \"\$@\"; }")
    eval "$original_cd"
    cd() {
        builtin cd "$@" && auto_venv_detect
    }
elif [[ "$ZSH_VERSION" ]]; then
    # Zsh
    autoload -U add-zsh-hook
    add-zsh-hook chpwd auto_venv_detect
fi

# Aliases for convenience
alias lsvenv='list_venvs'
alias mkvenv='create_venv'
alias rmvenv='rm -rf'  # Be careful with this!
alias workon='switch_venv'

# Initial notification on shell startup
nvim_notify_venv_change

echo "🚀 Neovim Virtual Environment Integration loaded!"
echo "Available commands:"
echo "  create_venv [name] [python_version] - Create and optionally activate a virtual environment"
echo "  activate_venv <path>                - Activate a virtual environment"
echo "  list_venvs                          - List available virtual environments"
echo "  switch_venv [name]                  - Switch to a virtual environment"
echo "  toggle_nvim_venv_notify             - Toggle Neovim notifications"
echo
echo "Keymaps in Neovim:"
echo "  <leader>vp - Pick virtual environment"
echo "  <leader>vi - Show virtualenv info"
echo "  <leader>vs - Manually sync virtualenv"
echo "  <leader>vm - Toggle monitoring"