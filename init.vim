if &compatible
	set nocompatible
endif
set number
"set cursorline
set tabstop=4
set shiftwidth=4
set softtabstop=4
set backspace=2
set expandtab
set noswapfile
set nobackup

set wildmode=longest,list
set hlsearch

set clipboard+=unnamedplus

set runtimepath+=~/.dotfiles/vim/dein.vim

if dein#load_state('~/.cache/dein')
	call dein#begin('~/.cache/dein')
	call dein#add('scrooloose/nerdtree')
	call dein#add('vim-scripts/xoria256.vim')
	call dein#add('Shougo/denite.nvim')
	call dein#add('Shougo/deoplete.nvim')
	call dein#end()
	call dein#save_state()
endif

set statusline=%{expand('%:p:t')}\ %<[%{expand('%:p:h')}]\ %n%=\ %m%r%y%m[%{&fenc!=''?&fenc:&enc}][%{&ff}][%3l,%3c,%3p%%]

nmap <ESC><ESC> :nohl<CR><ESC>
noremap <A-h> <C-w>h
noremap <A-j> <C-w>j
noremap <A-k> <C-w>k
noremap <A-l> <C-w>l
inoremap <A-h> <Esc><C-w>h
inoremap <A-j> <Esc><C-w>j
inoremap <A-k> <Esc><C-w>k
inoremap <A-l> <Esc><C-w>l
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l

if has('nvim')
    autocmd WinEnter * if &buftype == 'terminal' | startinsert | endif
endif
filetype plugin indent on
syntax enable


if dein#tap('denite.nvim')
    autocmd FileType denite call s:denite_key_mappings()
    function! s:denite_key_mappings() abort
        nnoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
        nnoremap <silent><buffer><expr> p denite#do_map('do_action', 'preview')
        nnoremap <silent><buffer><expr> q denite#do_map('quit')
        nnoremap <silent><buffer><expr> i denite#do_map('open_filter_buffer')
    endfunction

    nmap <Space> [Denite]
    nnoremap <silent> [Denite]b :<C-u>DeniteBufferDir buffer file/rec<CR>
    nnoremap <silent> [Denite]f :<C-u>DeniteBufferDir file/rec<CR>

endif

let g:deoplete#enable_at_startup=1
