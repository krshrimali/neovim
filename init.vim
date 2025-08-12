" Neovim Configuration with Clipboard Integration
" Place this file at ~/.config/nvim/init.vim

" Basic settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab

" Function to setup clipboard
function! SetupClipboard()
    " Check if we're in WSL
    if has('wsl')
        let g:clipboard = {
            \ 'name': 'WslClipboard',
            \ 'copy': {
            \   '+': 'clip.exe',
            \   '*': 'clip.exe',
            \ },
            \ 'paste': {
            \   '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            \   '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            \ },
            \ 'cache_enabled': 0,
            \ }
        echo "WSL clipboard configured"
    " Check for macOS
    elseif has('mac')
        set clipboard=unnamedplus
        echo "macOS clipboard configured"
    " Check for Linux clipboard utilities
    elseif executable('xclip')
        set clipboard=unnamedplus
        echo "Linux clipboard configured with xclip"
    elseif executable('xsel')
        set clipboard=unnamedplus
        echo "Linux clipboard configured with xsel"
    elseif executable('wl-copy')
        set clipboard=unnamedplus
        echo "Wayland clipboard configured"
    else
        echo "Warning: No clipboard provider found!"
        echo "Install xclip, xsel, or wl-clipboard-tools"
        echo "You can still use \"+y and \"+p for manual clipboard operations"
    endif
endfunction

" Set up clipboard
call SetupClipboard()

" Key mappings for manual clipboard operations (fallback)
vnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" Function to check clipboard status
function! CheckClipboard()
    echo "Clipboard status:"
    echo "has('clipboard'): " . has('clipboard')
    echo "Current clipboard setting: " . &clipboard
    
    echo "Available clipboard utilities:"
    let providers = ['xclip', 'xsel', 'wl-copy', 'pbcopy', 'clip.exe']
    for provider in providers
        if executable(provider)
            echo "  ✓ " . provider
        else
            echo "  ✗ " . provider
        endif
    endfor
endfunction

" Command to check clipboard status
command! CheckClipboard call CheckClipboard()

" Auto-command to show clipboard status on startup
augroup ClipboardStatus
    autocmd!
    autocmd VimEnter * call timer_start(100, {-> execute('call CheckClipboardOnStartup()')})
augroup END

function! CheckClipboardOnStartup()
    if !empty(&clipboard)
        echo "✓ System clipboard integration enabled"
    else
        echo "⚠ System clipboard not configured - use :CheckClipboard for details"
    endif
endfunction

echo "Neovim configuration loaded!"