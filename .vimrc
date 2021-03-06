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
  Plugin 'ervandew/supertab'
  Plugin 'airblade/vim-gitgutter'

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
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
" }}}

" ALE Configuration (ASync Linting Engine) {{{
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'html': ['HTMLHint'],
      \ 'bash': ['shellcheck'],
      \ 'rust': ['rustc'],
      \ 'text': ['vale'],
      \ 'markdown': ['vale'],
      \ 'latex': ['vale'],
      \ 'yaml': ['prettier'],
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
:set hidden " Any buffer can be hidden, without changes being saved first
:set nolist wrap linebreak breakat&vim " Line breaks at whitespace
 
" Normal behaviour for backspace
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

:set splitright " When doing a vertical split, split to the right
:set splitbelow " When doing a horizontal split, create new window on the bottom

if $TMUX == ''
  set clipboard=unnamed
endif
" }}}

" File-type specific settings {{{
augroup strip-trailing
  autocmd!
  autocmd BufWritePre *.php, *.js, *.jsx, *.html, *.txt, *.md, *.java, *.py, *.c, *.cpp, *.css, *.scss, .vimrc, .zshrc
    \:call <SID>StripTrailingWhiteSpaces() " Strips trailing white space from files
augroup END

" Make it easier to follow git convention by wrapping lines at 72 characters
augroup wrap-git-commit-lines
  autocmd!
  au FileType gitcommit set tw=72
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
" Ignore case when searching
set ignorecase
" Be smart about cases
set smartcase
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
