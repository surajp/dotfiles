" Author: Johannes Wienke <languitar@semipol.de>
" Description: PMD for Java files

function! ale_linters#apex#pmd#Handle(buffer, lines) abort
    let l:pattern = '"\(\d\+\)",".*","\(.\+\)","\(\d\+\)","\(\d\+\)","\(.\+\)","\(.\+\)","\(.\+\)"$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': 'W',
        \   'lnum': l:match[4] + 0,
        \   'text': l:match[5],
        \   'code': l:match[6] . ' - ' . l:match[7],
        \})
    endfor

    return l:output
endfunction

function! ale_linters#apex#pmd#GetCommand(buffer) abort
    return $HOME.'/lib/pmd/pmd/bin/pmd check --no-progress'
    \ . ale#Var(a:buffer, 'apex_pmd_options')
    \ . ' -f csv'
    \ . ' -d %t'
endfunction

if !exists('g:ale_apex_pmd_options')
    let g:ale_apex_pmd_options = ' -R rulesets/apex/quickstart.xml'
endif

call ale#linter#Define('apex', {
\   'name': 'pmd',
\   'executable': $HOME.'/lib/pmd/pmd/bin/pmd',
\   'command': function('ale_linters#apex#pmd#GetCommand'),
\   'callback': 'ale_linters#apex#pmd#Handle',
\})
