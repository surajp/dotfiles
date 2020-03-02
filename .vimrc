set relativenumber
syntax on
set noexpandtab
set copyindent
set preserveindent
set softtabstop=0
set tabstop=2
set shiftwidth=2
set smartindent
set background=dark
colorscheme solarized

augroup FileTypeGroup
	autocmd!
	au BufRead,BufNewFile *.cls set filetype=java
	au BufRead,BufNewFile *.trigger set filetype=java
	au BufRead,BufNewFile *.cmp set filetype=html
	au BufRead,BufNewFile *.vue set filetype=html
	au BufRead,BufNewFile *.tsx set filetype=javascript
	au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
augroup END

call plug#begin('~/.vim/plugged')

Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
Plug 'altercation/vim-colors-solarized'

call plug#end()

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

let g:prettier#config#print_width = 150

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.git','pom.xml','.ssh','node_modules']
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
" let g:netrw_banner = 0
" let g:netrw_browse_split = 3 
" let g:netrw_winsize = 25
" au BufRead /tmp/psql.edit.* set syntax=sql
"
" Ultisnips Trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" Ctrl p exclude directories
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|src'

let g:ale_fixers = {'javascript': ['eslint','prettier']}
let g:ale_sign_error='❌'
let g:ale_sign_warning='⚠️'

let g:ale_javascript_eslint_executable = 'eslint'
let g:ale_javascript_eslint_use_global = 1