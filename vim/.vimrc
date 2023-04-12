filetype plugin indent on
colorscheme ron
set statusline+=%F\ %l\:%c
set nu
set hls
set laststatus=2
set tabstop=4
set shiftwidth=4
set expandtab
set scrolloff=5
set ai
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use
set updatetime=100
set splitbelow
set splitright
set visualbell
set breakindent
let g:gitgutter_terminal_reports_focus=0
nnoremap <CR> :noh<CR><CR>
:command W noa w

" Uncomment the following blocks to enable Ctrl-J HexMode
" nnoremap <C-J> :Hexmode<CR>
" inoremap <C-J> <Esc>:Hexmode<CR>
" vnoremap <C-J> :<C-U>Hexmode<CR>

" " ex command for toggling hex mode - define mapping if desired
" command -bar Hexmode call ToggleHex()

" " helper function to toggle hex mode
" function ToggleHex()
"   " hex mode should be considered a read-only operation
"   " save values for modified and read-only for restoration later,
"   " and clear the read-only flag for now
"   let l:modified=&mod
"   let l:oldreadonly=&readonly
"   let &readonly=0
"   let l:oldmodifiable=&modifiable
"   let &modifiable=1
"   if !exists("b:editHex") || !b:editHex
"     " save old options
"     let b:oldft=&ft
"     let b:oldbin=&bin
"     " set new options
"     setlocal binary " make sure it overrides any textwidth, etc.
"     silent :e " this will reload the file without trickeries
"               "(DOS line endings will be shown entirely )
"     let &ft="xxd"
"     " set status
"     let b:editHex=1
"     " switch to hex editor
"     %!xxd
"   else
"     " restore old options
"     let &ft=b:oldft
"     if !b:oldbin
"       setlocal nobinary
"     endif
"     " set status
"     let b:editHex=0
"     " return to normal editing
"     %!xxd -r
"   endif
"   " restore values for modified and read only state
"   let &mod=l:modified
"   let &readonly=l:oldreadonly
"   let &modifiable=l:oldmodifiable
" endfunction

execute pathogen#infect()
syntax on
filetype plugin on

let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
set statusline+=%{fugitive#statusline()}

autocmd BufWritePre * %s/\s\+$//e

let g:rainbow_active = 1
let g:rainbow_conf = {
    \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
    \   'operators': '_,_',
    \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \   'separately': {
    \       '*': {},
    \       'tex': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \       },
    \       'lisp': {
    \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
    \       },
    \       'vim': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
    \       },
    \       'html': {
    \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \       },
    \       'css': 0,
    \   }
    \}

" Trigger `autoread` when files changes on disk
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" Notification after file change
" https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

let @q = 'Oimport codecode.interact(local=dict(globals(), **locals()))'

" BRG new
set signcolumn=yes
highlight! link SignColumn LineNr
" let g:gitgutter_set_sign_backgrounds = 1
