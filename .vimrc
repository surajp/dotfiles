set relativenumber
syntax on
set cursorline
set noexpandtab
set copyindent
set preserveindent
set softtabstop=0
set tabstop=2
set shiftwidth=2
set smartindent

au BufRead,BufNewFile *.cls set filetype=java
au BufRead,BufNewFile *.cmp set filetype=html
au BufRead,BufNewFile *.vue set filetype=html
au BufRead,BufNewFile *.tsx set filetype=javascript
au BufRead,BufNewFile *.jsx set filetype=javascript

call plug#begin('~/.vim/plugged')

Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'

call plug#end()

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

let g:prettier#config#print_width = 150

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.git','pom.xml','.ssh','node_modules']
let g:netrw_banner = 0
let g:netrw_browse_split = 3 
let g:netrw_winsize = 25
" au BufRead /tmp/psql.edit.* set syntax=sql
