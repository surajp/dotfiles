call plug#begin('~/.vim/plugged')

"Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
"Plug 'altercation/vim-colors-solarized'

Plug 'dart-lang/dart-vim-plugin'
"Plug 'neovim/nvim-lspconfig'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()


set number relativenumber
syntax on
set noexpandtab
set copyindent
set preserveindent

let $RTP = $XDG_CONFIG_HOME."/nvim"
set tabstop=2
set shiftwidth=2
set expandtab

set colorcolumn=120

"set cursor to blink
"set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175
set cursorline

" Use ALE for Omnifunc
set omnifunc=ale#completion#OmniFunc
set background=dark
" colorscheme solarized
colorscheme desert

" Set foldmethod
set foldmethod=syntax
set foldlevel=1
set foldnestmax=2

" Dictionary
set dictionary+=/usr/share/dict/words
set complete+=k

" Set blinking cursor
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175

filetype plugin on
filetype plugin indent on

augroup FileTypeGroup
	autocmd!
	au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
	au BufRead,BufNewFile *.soql set filetype=apex | set syntax=sql | UltiSnipsAddFiletypes sql
	au BufRead,BufNewFile *-meta.xml UltiSnipsAddFiletypes meta.xml
	au BufRead,BufNewFile project-scratch-def.json set filetype=scratch | set syntax=json
	au BufRead,BufNewFile *.vue,*.svelte,*.jsw,*.cmp,*.page set filetype=html
	au BufRead,BufNewFile *.tsx,*.jsw set filetype=javascript
	au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
	au BufRead,BufNewFile **/lwc/*.js UltiSnipsAddFiletypes lwc.js
augroup END



" Set current directory to the parent dir of the current file
" autocmd BufEnter * silent! lcd %:p:h

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

"Keymaps
" Press Space to turn off highlighting and clear any message already displayed.
let hlstate=0
:nnoremap <silent> <Space> :if (hlstate%2 == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=hlstate+1<Bar>:echo<CR>
:nnoremap <C-j>t :bo 15sp +te<CR>A
:nnoremap <C-w>m <C-w>_<C-w>\|
:nnoremap <C-w><Left> :vertical resize -5<CR>
:nnoremap <C-w><Right> :vertical resize +5<CR>
:nnoremap <C-w><Down> :resize +5<CR>
:nnoremap <C-w><Up> :resize +5<CR>
:nnoremap <C-s> :ls<CR>:b<Space>
":nnoremap <C-y> [{zf%
:nnoremap zm zMza
:nnoremap zr zR
:noremap <C-e> :tabnew ~/.vimrc<CR>
:nnoremap ++ :!git add %<CR>
:nnoremap ]t :!sfdx force:apex:test:run -y -r human -c -w 5 -n %:t:r --verbose<CR>
:nnoremap <silent> ]tt ?@isTest<CR>j0f(hyiw:!sfdx force:apex:test:run -y -r human -c -w 5 --verbose -t %:t:r.<C-r>"<CR>
:nnoremap ]a :!sfdx force:source:push<CR>
:nnoremap ]af :!sfdx force:source:push -f<CR>
:nnoremap ]u :!sfdx force:source:pull<CR>
:nnoremap ]uf :!sfdx force:source:pull -f<CR>
:nnoremap ]d :!sfdx force:source:deploy -p "%" -l NoTestRun -w 5 -u 
:nnoremap ]dd :!sfdx force:source:deploy -p "%" -l NoTestRun -w 5<CR>
:nnoremap ]e :!sfdx force:apex:execute -f % -u 
:nnoremap ]ee :!sfdx force:apex:execute -f %<CR>

"remap 'U' to revert to previous save
nnoremap U :ea 1f<CR>

"fzf key bindings
:nnoremap <C-p> :Files!<CR>
:nnoremap <silent> <C-f>b :Buffers!<CR>
:nnoremap <silent> <C-f>s :Snippets!<CR>
:nnoremap <silent> <C-f>g :Commits!<CR>
:nnoremap <silent> <C-f>f <Esc><Esc>:BLines!<CR>

inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

"ale key bindings
:nnoremap <silent> <C-w>i :ALEToggleBuffer<CR>

" use 'za' to toggle folds
" Prevent wq accidents
:command! W w
:command! Wq wq
:command! Wqa wqa

:command! Q q
:command! Qa qa


"Remap arrow keys
:nnoremap <Up> ddkP
:nnoremap <Down> ddp


let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.git','pom.xml','.ssh','node_modules']
" let g:netrw_banner = 0
" let g:netrw_browse_split = 3 
 let g:netrw_winsize = 25
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

let g:ale_linters = {'javascript': ['eslint'],'css':['eslint'],'html':['eslint'],'apex':['apexlsp','pmd'],'jsw':['eslint'],'markdown':['markdownlint']}
let g:ale_fixers = {'javascript': ['prettier'],'css':['prettier'],'apex':['prettier'],'html':['prettier'],'jsw':['prettier'],'json':['jq'],'python':['black'],'java':['google_java_format'],'markdown':['prettier']}
let g:ale_fix_on_save= 1
let g:ale_sign_error='>>'
"let g:ale_sign_warning='⚠️'
let g:ale_sign_warning='--'

let g:ale_javascript_eslint_executable = 'eslint'
let g:ale_javascript_eslint_use_global = 1
let g:ale_completion_tsserver_autoimport = 1
let g:ale_java_google_java_format_executable = "~/.scripts/jformat.sh"
let g:ale_apex_apexlsp_executable = "/usr/bin/java"

if $PATH !~ "\.scripts"
  let $PATH="~/.scripts/:".$PATH
endif


if (has("termguicolors"))
  set termguicolors
endif

"search recursively in subfolders using 'find'
set path+=**

"Ignore folders from vim grep
set wildignore+=**/node_modules/**

syntax sync minlines=10000

function! StatuslineSfdx(...) abort
  if !exists('./sfdx/sfdx-config.json')
    return ''
  endif
  return system("if [ -f './.sfdx/sfdx-config.json' ];then cat ./.sfdx/sfdx-config.json 2>/dev/null | jq -r '.defaultusername' 2>/dev/null; fi")
endfunction

" status line changes
set laststatus=2
let g:airline_section_a=airline#section#create(['%{StatuslineSfdx()}',' ','branch'])
"set statusline='%{StatuslineSfdx()}'

