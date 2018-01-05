" Vim configuration by Emil Teurnberg

" Vundle Initialisation {{{
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'altercation/vim-colors-solarized'
Plugin 'edkolev/tmuxline.vim'
Plugin 'w0rp/ale'
Plugin 'pangloss/vim-javascript'
Plugin 'rhysd/devdocs.vim'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
" }}}

" Solarized dark initialisation {{{
syntax enable
set background=dark
colorscheme solarized
let g:solarized_termcolors=256
" }}}

" Tabline related {{{
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text
:let g:airline_theme='solarized'
" }}}

" ALE Configuration (ASync Linting Engine) {{{
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'html': ['HTMLHint'],
      \ 'bash': ['shellcheck'],
      \ 'rust': ['rustc'],
      \}
" }}}

" Key bindings {{{
inoremap jj <Esc>
nnoremap <C-X> :tabn<CR>
nnoremap <C-A> :tabp<CR>
nmap <C-O> o<Esc>k
nmap <C-P> O<Esc>j
nnoremap <leader>sv :source $MYVIMRC<CR>

" Removes all whitespace in current file, restores last search term too
nnoremap <F5> :call <SID>StripTrailingWhiteSpaces()<CR>
" Move vertically by visual line
nnoremap j gj
nnoremap k gk
" }}}

" Generic editor {{{
:set number
:set tabstop=2
:set shiftwidth=2
:set expandtab
:set cursorline " Show a line indicator for where the cursor is
:set wildmenu " Visual autocomplete for command menu
:set showmatch " Highlight matching parenthesis

if $TMUX == ''
  set clipboard=unnamed
endif
" }}}

" Autogroups {{{
augroup configgroup
  autocmd!
  autocmd BufWritePre *.php, *.js, *.jsx, *.html, *.txt, *.md, *.java, *.py, *.c, *.cpp
    \:call <SID>StripTrailingWhiteSpaces() " Strips trailing white space from files
  au FileType gitcommit set tw=72 " Lines wrap at 72 chars in git commits (convention)
augroup END

" Overrides K in specific filetypes (for devdocs plugin search)
augroup plugin-devdocs
  autocmd!
  autocmd FileType c,rust,haskell,javascript nmap <buffer>K <Plug>(devdocs-under-cursor)
augroup END
" }}}

" Tmux {{{
" Allows cursor mode to be preserved when using tmux
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" }}}

" Searching {{{
" Turns of search highlight after search is done
nnoremap <leader><space> :nohlsearch<CR>
" Highlights last inserted text
nnoremap gV `[v`]
" }}}

" Autocompletion {{{
filetype plugin on
set omnifunc=syntaxcomplete#Complete
" }}}

" Swap files {{{
set swapfile
set directory=.,$TEMP
set shortmess+=A
" }}}

" Custom Functions {{{
" Strips trailing white spaces from the buffer
function! <SID>StripTrailingWhiteSpaces()
  " save last search & cursor position
  let _s=@/
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  let @/=_s
  call cursor(l, c)
endfunction
" }}}

" For file-specific  settings
set modelines=1 " Last line of this file only applied to this file.
" vim:fdm=marker:foldlevel=0
