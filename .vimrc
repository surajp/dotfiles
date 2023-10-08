
call plug#begin('~/.vim/plugged')

"Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
" Plug 'tpope/vim-vinegar'
Plug 'stevearc/oil.nvim'
Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
"Plug 'altercation/vim-colors-solarized'

Plug 'dart-lang/dart-vim-plugin'
" Plug 'neovim/nvim-lspconfig'

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


" Plug 'preservim/tagbar'

Plug 'stevearc/aerial.nvim'

call plug#end()

lua require 'init'

"Disable netrw
" let g:loaded_netrwPlugin=1

set number relativenumber
syntax on
set noexpandtab
set copyindent
set preserveindent
set lazyredraw
set ignorecase smartcase

let $RTP = $XDG_CONFIG_HOME."/nvim"
set tabstop=2
set shiftwidth=2
set expandtab

set colorcolumn=120

set hidden
set scrolloff=8

"set cursor to blink
"set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175
set cursorline

"disable mouse
set mouse=

"set spellcheck
set spell
set spelllang=en_us

" Use ALE for Omnifunc
set omnifunc=ale#completion#OmniFunc
set background=dark
" colorscheme gruvbox "using default colorscheme for now

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
set tsr+=/home/suraj/.mthesaur.txt

" Set blinking cursor
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175

filetype plugin on
filetype plugin indent on

augroup FileTypeGroup
	au!
	au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex | set syntax=apex
	"au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
	au BufRead,BufNewFile *.soql set filetype=apex | set syntax=sql | UltiSnipsAddFiletypes sql
	au BufRead,BufNewFile *-meta.xml UltiSnipsAddFiletypes meta.xml
	au BufRead,BufNewFile project-scratch-def.json set filetype=scratch | set syntax=json
	au BufRead,BufNewFile *.vue,*.svelte,*.jsw,*.cmp,*.page,*.component set filetype=html
	au BufRead,BufNewFile *.tsx,*.jsw set filetype=javascript
	au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
	au BufRead,BufNewFile **/lwc/*.js UltiSnipsAddFiletypes lwc.js
	au FileType qf :nnoremap <buffer> <CR> <CR> | set wh=15
augroup END




" Set current directory to the parent dir of the current file
" autocmd BufEnter * silent! lcd %:p:h

command! WipeReg for i in range(34,122) silent! call setreg(nr2char(i), []) endfor

"Keymaps

" Set current directory to the parent dir of the current file
nnoremap <leader>d  :lcd %:p:h<CR>

"Remap jk for <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

"Remap Enter to :
nnoremap <CR> :

"Make 'Y' same as 'C' and 'D'
nnoremap Y y$

"Remap in terminal mode
tnoremap <C-]> <C-\><C-n>

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
:noremap <leader>e :tabnew ~/.local/share/nvim/swap/<CR>
:nnoremap ++ :!git add "%"<CR>
:nnoremap ]t <C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -r human -w 5 -n "%:t:r"<CR>

"detailed coverage
:nnoremap ]td <C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n "%:t:r"<CR>
:nnoremap <leader>c :tabnew /tmp/coverage<CR>

":nnoremap ]t :set mp="sfdx apex:run:test -y -r human -c -w 5 -n \"%:t:r\" --verbose" \|exe 'make' \| copen<CR>
:nnoremap <silent> ]tt ?\c@IsTest<CR>j0f(hyiw<C-w>s<C-w>j10<C-w>-:term sfdx apex:run:test -y -c -r human -w 5 -t "%:t:r".<C-r>"<CR>:nohlsearch<CR>
:nnoremap ]a <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start<CR>
:nnoremap ]af <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -c<CR>
:nnoremap ]u <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start<CR>
:nnoremap ]uf <C-w>s<C-w>j10<C-w>-:term sfdx project:retrieve:start -c<CR>
:nnoremap ]d <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -d "%" -l NoTestRun -w 5 -o 
:nnoremap ]dd <C-w>s<C-w>j10<C-w>-:term sfdx project:deploy:start -d "%" -l NoTestRun -w 5<CR>
:nnoremap ]e :tabnew \| read !sfdx apex:run -f "#" -o 
:nnoremap ]ee :tabnew \| read !sfdx apex:run -f "#"<CR>
:nnoremap ]ej :tabnew \| read !sfdx apex:run -f "#" --json<CR>

"vim grep current word
:nnoremap ]ss yiw:vim /\c<C-r>"/g

"Buffer navigation
:nnoremap gn :bnext<CR>
:nnoremap gp :bprev<CR>

"apex logs
:nnoremap ]l :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color -o <bar> tee /tmp/apexlogs.log<C-left><C-left><C-left>
:nnoremap ]ll :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx apex:tail:log --color <bar> tee /tmp/apexlogs.log<CR>
:nnoremap ]li :tabnew \| read !sfdx apex:log:list
:nnoremap ]gl 0/\%<C-r>=line('.')<CR>l07L<CR>:nohlsearch<CR>"ayiw :tabnew \| read !sfdx force:apex:log:get -i <C-r>a

"remap 'U' to revert to previous save
nnoremap U :ea 1f<CR>

"fzf key bindings
:nnoremap <C-p> :Files!<CR>
:nnoremap <silent> <C-f>b :Buffers!<CR>
:nnoremap <silent> <C-f>s :Snippets!<CR>
:nnoremap <silent> <C-f>g :Commits!<CR>
:nnoremap <silent> <C-f>f <Esc><Esc>:BLines!<CR>
:nnoremap <silent> <C-f>l <Esc><Esc>:Helptags!<CR>

"fzf options
let $FZF_DEFAULT_OPTS="--preview-window 'right:50%' --margin=1,4 --bind=alt-k:preview-page-up,alt-j:preview-page-down --preview='if [[ -f {} || -d {} ]];then batcat {};fi'"

"git log graph using fugitive
:nnoremap <silent> <leader>g :G log --all --decorate --graph --pretty=format:"%h%x09%an%x09%ad%x09%s"<CR>

inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" Dictionary using fzf and wordnet
imap <C-S> <Plug>(fzf-complete-wordnet)

inoremap <expr> <C-x>c fzf#vim#complete('cat ~/.sldsclasses.txt') 
inoremap <expr> <Leader>s fzf#vim#complete({
      \ 'source': 'cat schema.txt',
      \ 'reducer': { lines -> split(lines[0],' ')[0]}})

"ale key bindings
:nnoremap <silent> <C-w>i :ALEToggleBuffer<CR>

" use 'za' to toggle folds
" Prevent wq accidents
:command! -bang W w
:command! -bang Wq wq
:command! -bang Wqa wqa

:command! -bang Q q
:command! -bang Qa qa

" Prevent gq accidents
:nnoremap gQ gq

"Remap arrow keys
:nnoremap <Up> ddkP
:nnoremap <Down> ddp

"sudo save
cmap w!! w !sudo tee > /dev/null %

"remove all tabs and spaces from lines with just tabs and spaces to make them
"truly blank lines
:command! BL %s/^\(\s\|\t\)*$//g

"aerial maps
:nnoremap mm :AerialToggle<CR>

"xml to json map
:nnoremap <Leader>$ :%!fxparser <bar> jq<CR> :set ft=json<CR>ggj4dd
:nnoremap <Leader># :ea 1f<CR>:set ft=xml<CR>

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

let g:ale_linters = {'javascript': ['eslint'],'css':['eslint'],'html':['eslint'],'apex':['apexlsp','pmd'],'java':['javalsp'],'jsw':['eslint'],'markdown':['markdownlint'],'rust':['analyzer'],'sh':['shellcheck'],'typescript':['tsserver']}
let g:ale_fixers = {'javascript': ['prettier'],'css':['prettier'],'apex':['prettier'],'html':['prettier'],'jsw':['prettier'],'json':['jq'],'python':['black'],'java':['google_java_format'],'markdown':['prettier'],'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],'sh':['shfmt'],'xml':['tidy']}
let g:ale_fix_on_save= 1
let g:ale_sign_error='>>'
"let g:ale_sign_warning='⚠️'
let g:ale_sign_warning='--'
let g:ale_floating_preview=1
let g:ale_apex_apexlsp_jarfile='/home/suraj/libs/apex-jorje-lsp.jar'

let g:ale_javascript_eslint_executable = 'eslint'
let g:ale_javascript_eslint_use_global = 1
let g:ale_completion_tsserver_autoimport = 1
let g:ale_java_google_java_format_executable = "~/.scripts/jformat.sh"
" let g:ale_apex_apexlsp_executable = "/usr/bin/java"

"Command to toggle fixers
command! ALEDisableFixers execute "let b:ale_fix_on_save = 0"
command! ALEToggleFixers execute "let b:ale_fix_on_save = get(b:,'ale_fix_on_save',0)?0:1"

function! CheckDisableALE() abort
  if luaeval('vim.fn.line("$")') > 500
    execute "ALEDisableBuffer"
    execute "ALEDisableFixers"
  endif
endfunction

augroup ALEGroup
  au!
  au BufRead * call CheckDisableALE() "diable ALE and fixers for big files
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
  ensure_installed = {"java","json","javascript","bash","lua","vim","comment","markdown","apex","soql","sosl"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
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


require('aerial').setup({})

EOF

" Copilot mappings
let g:copilot_assume_mapped = v:true
imap <silent><expr> <C-Space> copilot#Accept('\<CR>')
" :lua require('lsp') need to figure out how to get this to work
