" Stock vim configuration
filetype plugin indent on
set statusline+=%F\ %l\:%c
set nu                  " Line numbering
set hls                 " Highlight all search matches
set laststatus=2        " Always display the status line
set tabstop=4           " A tab is 4 spaces
set shiftwidth=4        " Spaces in 1 level of indentation
set expandtab           " Tab key expands to 4 spaces
set scrolloff=5         " Scroll offset of 5 lines
set autoindent          " Enable auto indent
set foldmethod=indent   " Fold based on indent
set foldnestmax=10      " Deepest fold is 10 levels
set nofoldenable        " Don't fold by default
set foldlevel=1        
set updatetime=100
set splitbelow          " Vertical splits go below
set splitright          " Horizontal splits go to the right
set visualbell          " Disable termial beeps
set breakindent         " Indent word-wrapped lines
autocmd BufWritePre * %s/\s\+$//e

" Command configration

"   Pressing ENTER will remove the hls highlighting
nnoremap <CR> :noh<CR><CR>

"   Writing a file with ":W" will not invoke the BufWritePre to
"   strip trailing whitespace.
:command W noa w

"   Use "@q" to inject code to drop into the Python debugger
"   above the current line.
let @q = 'Oimport codecode.interact(local=dict(globals(), **locals()))'

"   https://unix.stackexchange.com/a/383044
"   Triger `autoread` when files changes on disk
"     https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
"     https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

"   Notification after file change
"     https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" END Stock vim configuration

" PLUGIN CONFIGURATION

" Automatically install vim-plug
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify plugins
" https://github.com/junegunn/vim-plug#example
call plug#begin()

Plug 'tpope/vim-fugitive'      " https://github.com/tpope/vim-fugitive
Plug 'preservim/nerdcommenter' " https://github.com/preservim/nerdcommenter
Plug 'luochen1990/rainbow'     " https://github.com/luochen1990/rainbow
Plug 'airblade/vim-gitgutter'  " https://github.com/airblade/vim-gitgutter

call plug#end()

" vim-fugative options
set statusline+=%{FugitiveStatusline()}

" NERD Commenter Options
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'

" Rainbow parens Options
let g:rainbow_active = 1

" vim-gitgutter Options
let g:gitgutter_terminal_reports_focus=0
set signcolumn=yes
highlight! link SignColumn LineNr
