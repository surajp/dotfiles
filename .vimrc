lua require 'init'

call plug#begin('~/.vim/plugged')

"Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'dense-analysis/ale'
"Plug 'altercation/vim-colors-solarized'

Plug 'dart-lang/dart-vim-plugin'
"Plug 'neovim/nvim-lspconfig'

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

call plug#end()


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

" Use ALE for Omnifunc
set omnifunc=ale#completion#OmniFunc
set background=dark
" colorscheme solarized
"colorscheme desert
colorscheme gruvbox
"autocmd VimEnter * ++nested colorscheme enfocado if filereadable(".last.sess") | :source .last.sess | endif

"save state on quit
"autocmd VimLeave * :mksession! .last.sess


" Set foldmethod
set foldmethod=expr " if we set foldmethod to 'syntax' we would have to enable vim syntax on top of treesitter which can affect performance
set foldexpr=nvim_treesitter#foldexpr()
"set foldmethod=syntax
set foldlevel=1
set foldnestmax=3 " tree sitter only seems to fold at the method level

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
	au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex
	"au BufRead,BufNewFile *.cls,*.trigger,*.apex set filetype=apex | set syntax=java | UltiSnipsAddFiletypes cls.java
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
:noremap <leader>e :tabnew ~/.local/share/nvim/swap/<CR>
:nnoremap ++ :!git add "%"<CR>
:nnoremap ]t <C-w>s<C-w>j10<C-w>-:term sfdx force:apex:test:run -y -r human -c -w 5 -n "%:t:r" --verbose<CR>
":nnoremap ]t :set mp="sfdx force:apex:test:run -y -r human -c -w 5 -n \"%:t:r\" --verbose" \|exe 'make' \| copen<CR>
:nnoremap <silent> ]tt ?\c@IsTest<CR>j0f(hyiw<C-w>s<C-w>j10<C-w>-:term sfdx force:apex:test:run -y -r human -c -w 5 --verbose -t "%:t:r".<C-r>"<CR>
:nnoremap ]a <C-w>s<C-w>j10<C-w>-:term sfdx force:source:beta:push<CR>
:nnoremap ]af <C-w>s<C-w>j10<C-w>-:term sfdx force:source:beta:push -f<CR>
:nnoremap ]u <C-w>s<C-w>j10<C-w>-:term sfdx force:source:beta:pull<CR>
:nnoremap ]uf <C-w>s<C-w>j10<C-w>-:term sfdx force:source:beta:pull -f<CR>
:nnoremap ]d <C-w>s<C-w>j10<C-w>-:term sfdx force:source:deploy -p "%" -l NoTestRun -w 5 -u 
:nnoremap ]dd <C-w>s<C-w>j10<C-w>-:term sfdx force:source:deploy -p "%" -l NoTestRun -w 5<CR>
:nnoremap ]e :tabnew \| read !sfdx force:apex:execute -f "#" -u 
:nnoremap ]ee :tabnew \| read !sfdx force:apex:execute -f "#"<CR>

"apex logs
:nnoremap ]l :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx force:apex:log:tail --color -u <bar> tee /tmp/apexlogs.log<C-left><C-left><C-left>
:nnoremap ]ll :tabnew /tmp/apexlogs.log<CR><C-w>s<C-w>j:term sfdx force:apex:log:tail --color <bar> tee /tmp/apexlogs.log<CR>

"remap 'U' to revert to previous save
nnoremap U :ea 1f<CR>

"fzf key bindings
:nnoremap <C-p> :Files!<CR>
:nnoremap <silent> <C-f>b :Buffers!<CR>
:nnoremap <silent> <C-f>s :Snippets!<CR>
:nnoremap <silent> <C-f>g :Commits!<CR>
:nnoremap <silent> <C-f>f <Esc><Esc>:BLines!<CR>
":nnoremap <silent> <C-f>l <Esc><Esc>:Helptags!<CR>

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
:command! W w
:command! Wq wq
:command! Wqa wqa

:command! Q q
:command! Qa qa

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

"set local directory to current file's directory
:nnoremap <Leader>lcd :lcd %:p:h<CR>

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

let g:ale_linters = {'javascript': ['eslint'],'css':['eslint'],'html':['eslint'],'apex':['apexlsp','pmd'],'jsw':['eslint'],'markdown':['markdownlint'],'rust':['analyzer'],'sh':['shellcheck']}
let g:ale_fixers = {'javascript': ['prettier'],'css':['prettier'],'apex':['prettier'],'html':['prettier'],'jsw':['prettier'],'json':['jq'],'python':['black'],'java':['google_java_format'],'markdown':['prettier'],'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],'sh':['prettier']}
let g:ale_fix_on_save= 1
let g:ale_sign_error='>>'
"let g:ale_sign_warning='⚠️'
let g:ale_sign_warning='--'
let g:ale_floating_preview=1

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
"let g:airline_section_a=airline#section#create(['%{StatuslineSfdx()}',' ','branch'])
"set statusline='%{StatuslineSfdx()}'

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"java","json","javascript","bash","lua","vim","comment"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
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

local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
ft_to_parser.apex = "java" 

EOF
