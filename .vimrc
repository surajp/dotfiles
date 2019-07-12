set relativenumber
syntax on
set cursorline
set tabstop=4
set shiftwidth=4
set smartindent
au BufRead,BufNewFile *.cls setfiletype=java
au BufRead,BufNewFile *.cmp setfiletype=html

call plug#begin('~/.vim/plugged')

Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

let g:prettier#config#print_width = 150
