" vim:fdm=marker

" Vundle Initialisation {{{
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'altercation/vim-colors-solarized'
Plugin 'digitaltoad/vim-pug'
Plugin 'edkolev/tmuxline.vim'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
" }}}

" Solarized dark initialisation {{{ 
syntax enable
set background=dark
colorscheme solarized
" }}}

" Tabline related {{{ 
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text
:let g:airline_theme='solarized'
" }}}

" Key bindings {{{ 
:inoremap jj <Esc>
:nnoremap <C-X> :tabn<CR>
:nnoremap <C-A> :tabp<CR>
" }}}

" Generic editor {{{
filetype plugin indent on
:set number
:set tabstop=4
:set shiftwidth=4
:set expandtab

" Removes trailing whitespace for certain filetypes
autocmd FileType js,jsx,html autocmd BufWritePre <buffer> :%s/\s\+$//e
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
