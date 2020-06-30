call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
"Plug 'altercation/vim-colors-solarized'
Plug 'dart-lang/dart-vim-plugin'

call plug#end()

set number relativenumber
syntax on
set noexpandtab
set copyindent
set preserveindent

filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab
set foldmethod=marker

" Use ALE for Omnifunc
set omnifunc=ale#completion#OmniFunc
set background=dark
" colorscheme solarized
colorscheme pablo

" Set foldmethod
set foldmethod=marker

augroup FileTypeGroup
	autocmd!
	au BufRead,BufNewFile *.cls set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
	au BufRead,BufNewFile *.trigger set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
	au BufRead,BufNewFile *.apex set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
	au BufRead,BufNewFile *.cmp set filetype=html
	au BufRead,BufNewFile project-scratch-def.json set filetype=scratch | set syntax=json
	au BufRead,BufNewFile *.vue set filetype=html
	au BufRead,BufNewFile *.tsx set filetype=javascript
	au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
	"For Wix files
	au BufRead,BufNewFile *.jsw set filetype=javascript
augroup END

" Set current directory to the parent dir of the current file
" autocmd BufEnter * silent! lcd %:p:h

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

"Keymaps
" Press Space to turn off highlighting and clear any message already displayed.
let hlstate=0
:nnoremap <silent> <Space> :if (hlstate%2 == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=hlstate+1<Bar>:echo<CR>
:nnoremap <C-e> :bo 15sp +te<CR>A
:nnoremap <C-w>m <C-w>_<C-w>\|
:nnoremap <C-w><Left> :vertical resize -5<CR>
:nnoremap <C-w><Right> :vertical resize +5<CR>
:nnoremap <C-w><Down> :resize +5<CR>
:nnoremap <C-w><Up> :resize +5<CR>
:nnoremap <C-b> :ls<CR>:b<Space>
:nnoremap <C-y> [{zf]}
" use 'za' to toggle folds
:command W w
:command Wq wq

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.git','pom.xml','.ssh','node_modules']
" let g:netrw_banner = 0
" let g:netrw_browse_split = 3 
" let g:netrw_winsize = 25
" au BufRead /tmp/psql.edit.* set syntax=sql
"
" Ultisnips Trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsListSnippets="<s-tab>"
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetDirectories=["UltiSnips",$HOME."/.vim/mysnips"]

" Ctrl p exclude directories
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|src'

" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1

let g:ale_linters = {'javascript': ['eslint'],'css':['eslint'],'html':['eslint'],'apex':['apexlsp','pmd'],'jsw':['eslint']}
let g:ale_fixers = {'javascript': ['prettier'],'css':['prettier'],'apex':['prettier'],'html':['prettier'],'jsw':['prettier'],'json':['jq']}
let g:ale_fix_on_save= 1
let g:ale_sign_error='❌'
let g:ale_sign_warning='⚠️'

let g:ale_javascript_eslint_executable = 'eslint'
let g:ale_javascript_eslint_use_global = 1
let g:ale_completion_tsserver_autoimport = 1

if $PATH !~ "\.scripts"
  let $PATH="~/.scripts/:".$PATH
endif
