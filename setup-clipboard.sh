#!/bin/bash

# Neovim Clipboard Setup Script
# This script installs necessary clipboard utilities and sets up Neovim configuration

echo "=== Neovim Clipboard Setup Script ==="
echo

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/debian_version ]]; then
            echo "debian"
        elif [[ -f /etc/redhat-release ]]; then
            echo "redhat"
        elif [[ -f /etc/arch-release ]]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to install clipboard utilities
install_clipboard_utils() {
    local os=$(detect_os)
    
    echo "Detected OS: $os"
    echo "Installing clipboard utilities..."
    
    case $os in
        "debian")
            sudo apt update
            sudo apt install -y xclip xsel
            ;;
        "redhat")
            if command -v dnf &> /dev/null; then
                sudo dnf install -y xclip xsel
            else
                sudo yum install -y xclip xsel
            fi
            ;;
        "arch")
            sudo pacman -S --noconfirm xclip xsel
            ;;
        "macos")
            echo "macOS has built-in clipboard support (pbcopy/pbpaste)"
            ;;
        *)
            echo "Unknown OS. Please install xclip and xsel manually."
            return 1
            ;;
    esac
    
    echo "Clipboard utilities installation completed."
}

# Function to backup existing config
backup_config() {
    local config_dir="$HOME/.config/nvim"
    
    if [[ -d "$config_dir" ]]; then
        local backup_dir="${config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing config to: $backup_dir"
        cp -r "$config_dir" "$backup_dir"
    fi
}

# Function to setup Neovim config
setup_neovim_config() {
    local config_dir="$HOME/.config/nvim"
    
    echo "Setting up Neovim configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Ask user for preference
    echo "Which configuration format do you prefer?"
    echo "1) Lua (init.lua) - Recommended for Neovim 0.5+"
    echo "2) VimScript (init.vim) - Traditional Vim configuration"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            if [[ -f "init.lua" ]]; then
                cp "init.lua" "$config_dir/init.lua"
                echo "✓ Copied init.lua to $config_dir/init.lua"
            else
                echo "Error: init.lua not found in current directory"
                return 1
            fi
            ;;
        2)
            if [[ -f "init.vim" ]]; then
                cp "init.vim" "$config_dir/init.vim"
                echo "✓ Copied init.vim to $config_dir/init.vim"
            else
                echo "Error: init.vim not found in current directory"
                return 1
            fi
            ;;
        *)
            echo "Invalid choice. Skipping configuration setup."
            return 1
            ;;
    esac
}

# Function to test clipboard
test_clipboard() {
    echo
    echo "Testing clipboard functionality..."
    
    # Check if nvim is available
    if ! command -v nvim &> /dev/null; then
        echo "Neovim is not installed. Please install Neovim first."
        return 1
    fi
    
    # Test clipboard utilities
    echo "Available clipboard utilities:"
    for util in xclip xsel wl-copy pbcopy clip.exe; do
        if command -v "$util" &> /dev/null; then
            echo "  ✓ $util"
        else
            echo "  ✗ $util"
        fi
    done
    
    echo
    echo "To test clipboard in Neovim:"
    echo "1. Start Neovim: nvim"
    echo "2. Type some text"
    echo "3. Select text in visual mode (v)"
    echo "4. Press 'y' to yank"
    echo "5. Try pasting in another application"
    echo
    echo "Or run ':CheckClipboard' in Neovim to see detailed status"
}

# Function to show PuTTY configuration help
show_putty_help() {
    echo
    echo "=== PuTTY Configuration for X11 Forwarding ==="
    echo
    echo "To enable clipboard forwarding in PuTTY:"
    echo "1. Open PuTTY Configuration"
    echo "2. Go to Connection → SSH → X11"
    echo "3. Check 'Enable X11 forwarding'"
    echo "4. Set X display location to: localhost:0.0"
    echo "5. Save your session"
    echo
    echo "On Windows, you also need an X Server:"
    echo "- Install VcXsrv: https://sourceforge.net/projects/vcxsrv/"
    echo "- Or install Xming: https://sourceforge.net/projects/xming/"
    echo "- Start the X server before connecting via PuTTY"
    echo
    echo "After connecting, verify with: echo \$DISPLAY"
    echo "Should show something like: localhost:10.0"
}

# Main execution
main() {
    echo "This script will:"
    echo "1. Install clipboard utilities (xclip, xsel)"
    echo "2. Setup Neovim configuration with clipboard integration"
    echo "3. Test clipboard functionality"
    echo
    
    read -p "Do you want to continue? (y/n): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    echo
    
    # Step 1: Install clipboard utilities
    if command -v xclip &> /dev/null && command -v xsel &> /dev/null; then
        echo "Clipboard utilities already installed."
    else
        install_clipboard_utils
    fi
    
    echo
    
    # Step 2: Setup Neovim config
    backup_config
    setup_neovim_config
    
    echo
    
    # Step 3: Test clipboard
    test_clipboard
    
    # Step 4: Show PuTTY help
    show_putty_help
    
    echo
    echo "=== Setup Complete ==="
    echo "Your Neovim should now have clipboard integration!"
    echo "If you're using PuTTY, make sure to follow the X11 forwarding instructions above."
}

# Run main function
main "$@"