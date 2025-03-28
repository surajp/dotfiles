call plug#begin('~/.vim/plugged')

"Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
" Plug 'tpope/vim-vinegar'
Plug 'stevearc/oil.nvim'

" Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
"Plug 'altercation/vim-colors-solarized'

Plug 'dart-lang/dart-vim-plugin'
Plug 'neovim/nvim-lspconfig'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"
" Dictionary using wordnet and fzf
Plug 'Avi-D-coder/fzf-wordnet.vim'

Plug 'tpope/vim-fugitive'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'unblevable/quick-scope'
Plug 'wellle/targets.vim'

Plug 'ncm2/float-preview.nvim'

"New Color scheme
"Plug 'wuelnerdotexe/vim-enfocado'

Plug 'rust-lang/rust.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'gruvbox-community/gruvbox'

Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

Plug 'preservim/tagbar'

Plug 'stevearc/aerial.nvim'

Plug 'smoka7/hop.nvim'

Plug 'mbbill/undotree'

Plug 'carbon-steel/detour.nvim'

Plug 'HiPhish/rainbow-delimiters.nvim'

Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'CopilotC-Nvim/CopilotChat.nvim'

"Buffer nav
Plug 'leath-dub/snipe.nvim'

"Darkfold
Plug 'aliqyan-21/darkvoid.nvim'

"Time spent
Plug 'QuentinGruber/timespent.nvim'

"Iceberg color scheme
Plug 'cocopon/iceberg.vim'

"Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'

call plug#end()

let mapleader=" "

lua require 'init'
lua require 'keymaps'
"lua require 'copilot_ls'
"lua require 'theme'
lua require 'lsp'
lua require 'dapconfig'


set number relativenumber
syntax on
set noexpandtab
set copyindent
set preserveindent
set lazyredraw
set ignorecase smartcase

let $RTP = $XDG_CONFIG_HOME."/nvim"
set tabstop=8
set shiftwidth=2
set softtabstop=2
set noexpandtab

set colorcolumn=120

set hidden
set scrolloff=8

"set cursor to blink
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175
set cursorline

"disable mouse
set mouse=

"disable scroll
:nmap <ScrollWheelUp> <nop>
:nmap <S-ScrollWheelUp> <nop>
:nmap <C-ScrollWheelUp> <nop>
:nmap <ScrollWheelDown> <nop>
:nmap <S-ScrollWheelDown> <nop>
:nmap <C-ScrollWheelDown> <nop>
:nmap <ScrollWheelLeft> <nop>
:nmap <S-ScrollWheelLeft> <nop>
:nmap <C-ScrollWheelLeft> <nop>
:nmap <ScrollWheelRight> <nop>
:nmap <S-ScrollWheelRight> <nop>
:nmap <C-ScrollWheelRight> <nop>

:imap <ScrollWheelUp> <nop>
:imap <S-ScrollWheelUp> <nop>
:imap <C-ScrollWheelUp> <nop>
:imap <ScrollWheelDown> <nop>
:imap <S-ScrollWheelDown> <nop>
:imap <C-ScrollWheelDown> <nop>
:imap <ScrollWheelLeft> <nop>
:imap <S-ScrollWheelLeft> <nop>
:imap <C-ScrollWheelLeft> <nop>
:imap <ScrollWheelRight> <nop>
:imap <S-ScrollWheelRight> <nop>
:imap <C-ScrollWheelRight> <nop>

"set spellcheck
set spell
set spelllang=en_us

" Use ALE for Omnifunc
set omnifunc=ale#completion#OmniFunc
set background=dark
"colorscheme gruvbox 
colorscheme catppuccin-mocha
"colorscheme darkvoid
"colorscheme iceberg

"autocmd VimEnter * ++nested colorscheme enfocado if filereadable(".last.sess") | :source .last.sess | endif

"save state on quit
"autocmd VimLeave * :mksession! .last.sess


" Set foldmethod
set foldmethod=expr " if we set foldmethod to 'syntax' we would have to enable vim syntax on top of treesitter which can affect performance
set foldexpr=nvim_treesitter#foldexpr()
"set foldmethod=syntax
set foldlevel=1
set foldnestmax=30 " tree sitter only seems to fold at the method level

" Dictionary
set dictionary+=/usr/share/dict/words
set complete+=k

" Thesaurus
"set tsr+=/home/suraj/.mthesaur.txt

" Set blinking cursor
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175

filetype plugin on
filetype plugin indent on

augroup FileTypeGroup
	au!
	au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex | set syntax=apex
	au BufRead,BufNewFile *.soql set filetype=apex | set syntax=sql | UltiSnipsAddFiletypes sql
	au BufRead,BufNewFile project-scratch-def.json set filetype=scratch | set syntax=json
	au BufRead,BufNewFile *.vue,*.svelte,*.jsw,*.cmp,*.page,*.component set filetype=html
	au BufRead,BufNewFile *.tsx,*.jsw set filetype=javascript
	au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
	au BufRead,BufNewFile *-meta.xml UltiSnipsAddFiletypes meta.xml
	au BufRead,BufNewFile **/lwc/*.js  set filetype=lwc | set syntax=javascript | UltiSnipsAddFiletypes lwc.js
	au BufRead,BufNewFile *.rc set filetype=sh
	au FileType qf :nnoremap <buffer> <CR> <CR> | set wh=15
	au FileType xml :nnoremap <buffer> <Leader>$ :%!fxparser <bar> jq<CR> :set ft=json<CR>ggj4dd
	au FileType json :nnoremap <buffer> <Leader># :ea 1f<CR>:set ft=xml<CR>

	"au FileType fugitive :nnoremap <buffer> <leader>p :G push<CR> | :nnoremap <buffer> <leader>pf :G pushf | :nnoremap <buffer> <leader>l :G pull<CR>
augroup END

" set b:workspace_folder by traversing up the directory tree to find the first sfdx-project.json file, for copilot
let s:find_workspace_folder = {path -> fnamemodify(findfile('sfdx-project.json', path . ';/Users/surajpillai/projects'), ':h')} 

augroup apexSpecific
  autocmd!
  autocmd FileType apex 
    \ let b:workspace_folder = s:find_workspace_folder(expand('%:p:h'))
augroup END

augroup lwcSpecific
  autocmd!
  autocmd FileType lwc 
    \ let b:workspace_folder = s:find_workspace_folder(expand('%:p:h'))
augroup END

" Set current directory to the parent dir of the current file
" autocmd BufEnter * silent! lcd %:p:h

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

"Keymaps

" Set current directory to the parent dir of the current file
nnoremap <leader>D  :lcd %:p:h<CR>

"remap increment decrement
nnoremap <A-a> <C-a>

"Remap jk for <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

"Remap to navigate visual lines
nnoremap j gj
nnoremap k gk

"Remap Enter to :
nnoremap <CR> :

"Remap in terminal mode
tnoremap <C-]> <C-\><C-n>

"Remap for quickfix
nnoremap <silent> <C-j> :cnext<CR>
nnoremap <silent> <C-k> :cprev<CR>

"Fugitive Git status quick launch
nnoremap <silent> <leader>m :G<CR>

" Press Space to turn off highlighting and clear any message already displayed.
let hlstate=0
:nnoremap <silent> ; :if (hlstate%2 == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=hlstate+1<Bar>:echo<CR>
:nnoremap <C-j>t :bo 15sp +te<CR>A
:nnoremap <C-w>m <C-w>_<C-w>\|
:nnoremap <silent> <C-w><Left> :vertical resize -5<CR>
:nnoremap <silent> <C-w><Right> :vertical resize +5<CR>
:nnoremap <silent> <C-w><Down> :resize +5<CR>
:nnoremap <silent> <C-w><Up> :resize +5<CR>
:nnoremap <C-s> :ls<CR>:b<Space>
":nnoremap <C-y> [{zf%
:nnoremap zm zMza
:nnoremap zr zR
:noremap <silent> <C-e> :tabnew ~/.config/nvim/init.vim<CR>
:noremap <silent> <Leader>l :tabnew ~/.config/nvim/lua<CR>
:noremap <silent> <leader>ow :tabnew ~/.local/share/nvim/swap/<CR>
:nnoremap <silent> ++ :!git add "%"<CR>

"Apex test mappings
"nnoremap ]t <C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -r human -w 5 -n "%:t:r"<CR>
nnoremap <silent> ]t :RunAsync sfdx apex:run:test -r human -w 5 -n %:t:r<CR>
nnoremap <silent> ]T :RunAsync sfdx apex:run:test -c -r human -w 5 -n %:t:r<CR>
":nnoremap ]T <C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -r human -w 5 -n "%:t:r" -o 
nnoremap ]to :RunAsync sfdx apex:run:test -r human -w 5 -n %:t:r -o 
nnoremap ]To :RunAsync sfdx apex:run:test -c -r human -w 5 -n %:t:r -o 
":nnoremap ]t :set mp="sfdx apex:run:test -y -r human -c -w 5 -n \"%:t:r\" --verbose" \|exe 'make' \| copen<CR>
"nnoremap <silent> ]tt ?\c@IsTest<CR>j0f(hyiw<C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -y -c -r human -w 5 -t "%:t:r".<C-r>"<CR>:nohlsearch<CR>
nnoremap <silent> ]tt ?\c@IsTest<CR>j0f(h"tyiw<C-o><CR>:execute "RunAsync sfdx apex:run:test -r human -w 6 -t ". expand("%:t:r"). ".<C-r>t"<CR>:nohlsearch<CR>
nnoremap <silent> ]tT ?\c@IsTest<CR>j0f(h"tyiw<C-o><CR>:execute "RunAsync sfdx apex:run:test -r human -c -w 6 -t ". expand("%:t:r"). ".<C-r>t"<CR>:nohlsearch<CR>
"nnoremap  ]TT ?\c@IsTest<CR>j0f(hyiw<C-w>s<C-w>j10<C-w>-:nohlsearch<CR>:term sfdx apex:run:test -y -c -r human -w 5 -t "%:t:r".<C-r>" -o 
nnoremap ]TT ?\c@IsTest<CR>j0f(h"tyiw:nohlsearch<CR>:execute "RunAsync sfdx apex:run:test -y -c -r human -w 5 -t " . expand("%:t:r") . ".<C-r>t -o

"detailed coverage
":nnoremap ]td <C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n "%:t:r"<CR>
nnoremap ]td :RunAsync sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n %:t:r<CR>
:nnoremap <leader>cc :tabnew /tmp/coverage<CR>

"Explain code using llama3
":nnoremap <silent> <leader>ai :tabnew \| term cat # \| ollama run sfgemma "Explain this code and suggest improvements"<CR>
":nnoremap <silent> leader>ai :tabnew \| term cat # > /tmp/analyze.txt && echo "//Explain this code and suggest improvements" >> /tmp/analyze.txt && cat /tmp/analyze.txt \| fabric -sp sf_dev --model gemma2:latest<CR><CR>
nnoremap <silent> <leader>ai :tabnew \| term cat # > /tmp/analyze.txt && echo "//Explain this code and suggest improvements" >> /tmp/analyze.txt && cat /tmp/analyze.txt \| fabric -sp sf_dev --model llama3.2:latest<CR><CR>
nnoremap <silent> <leader>af :tabnew \| term cat # > /tmp/analyze.txt && echo "\n//Explain this salesforce flow. Be precise and concise. Use bullet points to illustrate the process clearly. Call out the type of flow and how the flow is triggered as well. In the end give a 2-3 sentence summary of the flow and the business use case it is potentially solving for" >> /tmp/analyze.txt && cat /tmp/analyze.txt \| fabric -sp sf_dev --model gpt-4o-mini<CR><CR>

":nnoremap <silent> ]a <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start<CR>
:nnoremap <silent> ]a :RunAsync sfdx project:deploy:start<CR>
":nnoremap <silent> ]af <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -c<CR>
nnoremap <silent> ]af :RunAsync sfdx project:deploy:start -c<CR>
"nnoremap <silent> ]u <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start<CR>
nnoremap <silent> ]u :RunAsync sfdx project:retrieve:start<CR>
":nnoremap <silent> ]uf <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start -c<CR>
nnoremap <silent> ]uf :RunAsync sfdx project:retrieve:start -c<CR>
":nnoremap <leader>[ <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start -d "%" -o 
nnoremap <leader>[ :RunAsync sfdx project:retrieve:start -d % -o 
":nnoremap <silent> <leader>[[ <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start -d "%"<CR>
nnoremap <silent> <leader>[[ :RunAsync sfdx project:retrieve:start -d %<CR>
":nnoremap ]d <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -d "%" -l NoTestRun -w 5 -o 
nnoremap ]d :RunAsync sfdx project:deploy:start -d % -l NoTestRun -w 5 -o 
":nnoremap <silent> ]dd <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -d "%" -l NoTestRun -w 5<CR>
nnoremap <silent> ]dd :RunAsync sfdx project:deploy:start -d % -l NoTestRun -w 5<CR>
"nnoremap <silent> ]dd :RunAsync /Users/surajpillai/projects/anywhere-sfr-dashboard/scripts/zsh/deployUsingTooling.sh %<CR>
":nnoremap ]e :tabnew \| read !sfdx apex:run -f "#" -o 
nnoremap ]e :RunAsync sfdx apex:run -f % -o 
":nnoremap <silent> ]ee :tabnew \| read !sfdx apex:run -f "#"<CR>
nnoremap <silent> ]ee :RunAsync sfdx apex:run -f %<CR>
":nnoremap <silent> ]ej :tabnew \| read !sfdx apex:run -f "#" --json<CR>
nnoremap <silent> ]ej :RunAsync sfdx apex:run -f % --json<CR>

"vim grep current word
:nnoremap ]ss yiw:vim /\c<C-r>"/g

"Buffer navigation
:nnoremap <silent> gn :bnext<CR>
:nnoremap <silent> gp :bprev<CR>
:nnoremap <silent> <leader>- :bdelete!<CR>

"apex logs
:nnoremap ]l :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color -o <bar> tee /tmp/apexlogs.log<C-left><C-left><C-left>
:nnoremap ]ll :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color <bar> tee /tmp/apexlogs.log<CR>
:nnoremap ]li :tabnew \| read !sfdx apex:log:list
:nnoremap ]gl 0/\%<C-r>=line('.')<CR>l07L<CR>:nohlsearch<CR>"ayiw :tabnew \| read !sfdx force:apex:log:get -i <C-r>a

"remap 'U' to revert to previous save
nnoremap U :ea 1f<CR>

"detour keymaps
nnoremap <silent> <c-w>o :Detour<CR>
nnoremap <silent> <c-w>c :DetourCurrentWindow<CR>

"open current file in bat in tmux popup
nnoremap <silent> <c-w>b :Detour<CR>:term bat --paging=always "%"<CR>a

"undotree
nnoremap <leader>u :UndotreeToggle<CR>
if has("persistent_undo")
   let target_path = expand('~/.undodir')
    " create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif

    let &undodir=target_path
    set undofile
endif

"fzf vim grep
command! -bang -nargs=* GGrepI
  \ call fzf#vim#grep(
  \   'git grep -i --line-number -- '.fzf#shellescape(<q-args>),
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(
  \   <q-args>,
  \   {'options':['--preview','bat {} --color always']},<bang>0)

command! -bang -nargs=? -complete=file Commits
  \ call fzf#vim#commits(
  \   <q-args>,
  \   {'options':['--preview','git show --color=always $(cut -d " " -f1 {})']},<bang>0)

"fzf key bindings
:nnoremap <C-p> :Files!<CR>
:nnoremap <silent> <C-f>b :Buffers<CR>
:nnoremap <silent> <C-f>s :Snippets<CR>
:nnoremap <silent> <C-f>c :BCommits!<CR>
:nnoremap <silent> <C-f>f <Esc><Esc>:BLines!<CR>
:nnoremap <silent> <C-f>l <Esc><Esc>:Helptags!<CR>
:nnoremap <silent> <C-f>g "syiw:GGrepI <C-r>s<CR>
:nnoremap <silent> <C-f>m <plug>(fzf-maps-n)
:nnoremap <silent> <C-f>r <plug>(ale_find_references)
:nnoremap <silent> <C-f>t :Filetypes!<CR>
:nnoremap <silent> <C-f>o :Colors<CR>

inoremap <expr> <C-f>i fzf#vim#complete('cat ~/lib/.sldsicons.txt') 


"fzf options
let $FZF_DEFAULT_OPTS="--preview-window 'right:50%' --margin=1,4 --bind=alt-k:preview-page-up,alt-j:preview-page-down,ctrl-a:select-all"

" CTRL-Q to build quickfix list
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let s:is_transparent = 0
function! s:MakeTransparent()
  hi Normal guibg=NONE ctermbg=NONE
  hi NonText guibg=NONE ctermbg=NONE
  let s:is_transparent = 1
endfunction

function! s:RemoveTransparent()
  execute "colorscheme " . g:colors_name
  let s:is_transparent = 0
endfunction

function! s:ToggleTransparent()
  if s:is_transparent == 0
    call s:MakeTransparent()
  else
    call s:RemoveTransparent()
  endif
endfunction

" Toggle transparency
nnoremap <silent> <leader>tt :call <SID>ToggleTransparent()<CR>

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

"git log graph using fugitive
:nnoremap <silent> <leader>g :G log --all --decorate --graph --pretty=format:"%h%x09%an%x09%ad%x09%s"<CR>

inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" Dictionary using fzf and wordnet
imap <C-S> <Plug>(fzf-complete-wordnet)

inoremap <expr> <C-x>c fzf#vim#complete('cat ~/.sldsclasses.txt') 
inoremap <expr> <C-x>m fzf#vim#complete({
      \ 'source': 'cat schema.txt',
      \ 'reducer': { lines -> split(lines[0],' ')[0]}})

"ale key bindings
:nnoremap <silent> <C-w>i :ALEToggleBuffer<CR>
nnoremap <silent> <C-w>d :ALEDetail<CR>

" use 'za' to toggle folds
" Prevent wq accidents
:command! -bang W w
:command! -bang Wq wq
:command! -bang Wqa wqa

:command! -bang Q q
:command! -bang Qa qa

" Prevent gq accidents
:nnoremap gQ gq

nnoremap <leader>q :q<CR>

"Remap arrow keys
:nnoremap <up> <nop>
:nnoremap <down> <nop>

"sudo save
cmap w!! w !sudo tee > /dev/null %

"remove all tabs and spaces from lines with just tabs and spaces to make them
"truly blank lines
:command! BL %s/^\(\s\|\t\)*$//g

"aerial maps
":nnoremap mm :AerialToggle<CR>
:nnoremap mm :TagbarToggle<CR>

"Run fixers on-demand
nnoremap <silent> <leader>fo :ALEFix<CR>

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_root_markers = ['.git','pom.xml','.ssh','node_modules']
" let g:netrw_banner = 0
" let g:netrw_browse_split = 3 
 let g:netrw_winsize = 25
 let g:netrw_bufsettings = 'noma nomod nu nowrap ro nobl'
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

"Dock floating preview window
let g:float_preview#docked=1

let g:ale_linters = {'javascript': ['eslint'],'css':['eslint'],'html':['eslint'],'apex':['pmd'],'java':['javalsp'],'jsw':['eslint'],'markdown':['markdownlint'],'rust':['analyzer'],'sh':['shellcheck'],'typescript':['tsserver']}
let g:ale_fixers = {'javascript': ['prettier'],'lwc': ['prettier'],'css':['prettier'],'apex':['prettier'],'html':['prettier'],'jsw':['prettier'],'typescript':['prettier'],'json':['jq'],'python':['black'],'java':['google_java_format'],'markdown':['prettier'],'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],'sh':['shfmt'],'xml':['tidy']}
let g:ale_fix_on_save= 1
let g:ale_sign_error='>>'
"let g:ale_sign_warning='⚠️'
let g:ale_sign_warning='--'
let g:ale_floating_preview=1
let g:ale_apex_apexlsp_jarfile='/Users/surajpillai/lib/apex-jorje-lsp.jar'

let g:ale_javascript_eslint_executable = 'eslint'
let g:ale_javascript_eslint_use_global = 1
let g:ale_completion_tsserver_autoimport = 1
let g:ale_java_google_java_format_executable = "~/.scripts/jformat.sh"
" let g:ale_apex_apexlsp_executable = "/usr/bin/java"

"Command to toggle fixers
command! ALEDisableFixersBuffer execute "let b:ale_fix_on_save = 0"
command! ALEToggleFixers execute "let b:ale_fix_on_save = get(b:,'ale_fix_on_save',0)?0:1"

function! CheckDisableALE() abort
  if luaeval('vim.fn.line("$")') > 500
    execute "ALEDisableBuffer"
    execute "ALEDisableFixers"
  endif
endfunction

function! CheckDisableAll() abort
  if luaeval('vim.fn.strlen(vim.fn.join(vim.fn.getline(1,10002),""))') > 100000
    execute "ALEDisableBuffer"
    execute "ALEDisableFixersBuffer"
    setlocal syntax=off
    setlocal filetype=nofile
  endif
endfunction

augroup ALEGroup
  au!
  au BufRead * call CheckDisableALE() "diable ALE and fixers for big files
  au BufRead * call CheckDisableAll() "disable ALE and fixers for really big files
augroup END

if filereadable('config/pmd-rules.xml')
  let g:ale_apex_pmd_options = " -R config/pmd-rules.xml"
endif

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

" https://github.com/vim-airline/vim-airline/issues/2704
let g:airline#extensions#whitespace#symbol = '!' 

"let g:airline_section_a=airline#section#create(['%{StatuslineSfdx()}',' ','branch'])
"set statusline='%{StatuslineSfdx()}'

let g:tagbar_type_apex = {
    \ 'ctagstype': 'java',
    \ 'kinds' : [
        \ 'p:packages:1:0',
        \ 'f:fields:0:0',
        \ 'g:enum types',
        \ 'e:enum constants:0:0',
        \ 'i:interfaces',
        \ 'c:classes',
        \ 'm:methods',
        \ '?:unknown',
    \ ],
\ }

lua <<EOF

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"java","apex","json","csv","javascript","bash","lua","vim","comment","markdown","soql","sosl","sflog"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false
  }
}

require('parallelpopup').setup({
  sleep=1,
  left=100,
  top=5,
  height=20,
  width=90,
})
require('aerial').setup({})

-- require('llm').setup({
--   api_token = nil,
--   backend = 'ollama',
--   model = 'gempilot',
--   context_window = 2048,
--   url = 'http://localhost:11434',
--    request_body = {
--     options = {
--       temperature = 0.7,
--       top_p = 0.95,
--     }
--   },
--   fim = {
--     enabled = true,
--     prefix = "<fim_prefix>",
--     middle = "<fim_middle>",
--     suffix = "<fim_suffix>",
--   },
--   tokenizer = nil,
--   enable_suggestions_on_startup = true,
--   enable_suggestions_on_files = "*",
--   debounce_ms = 150,
--   disable_url_path_completion = false,
--   accept_keymap = "<Tab>",
--   dismiss_keymap = "<S-Tab>",
-- })
require 'vertex'

EOF

" Copilot mappings
imap <silent><expr> <C-l> copilot#Accept('\<CR>')
let g:copilot_assume_mapped = v:true
let g:copilot_no_tab_map = v:true
let g:copilot_filetypes = {
      \ 'xml': v:false
\ }

call <SID>MakeTransparent()
