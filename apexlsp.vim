" Author: Suraj Pillai <https://github.com/surajp>
" Description: Support for the Apex language server

call ale#Set('apex_apexlsp_executable', 'java')
call ale#Set('apex_apexlsp_jarfile', '/home/suraj/libs/apex-jorje-lsp.jar')
call ale#Set('apex_apexlsp_javamem','1024m')

function! ale_linters#apex#apexlsp#Executable(buffer) abort
    return ale#Var(a:buffer, 'apex_apexlsp_executable')
endfunction

function! ale_linters#apex#apexlsp#Jar(buffer) abort
    return ale#Var(a:buffer, 'apex_apexlsp_jarfile')
endfunction

function! ale_linters#apex#apexlsp#JavaMem(buffer) abort
    return ale#Var(a:buffer, 'apex_apexlsp_javamem')
endfunction

function! ale_linters#apex#apexlsp#Command(buffer) abort
    let l:executable = ale_linters#apex#apexlsp#Executable(a:buffer)
    let l:jarlocation = ale_linters#apex#apexlsp#Jar(a:buffer)

    let l:cmd = [
    \ ale_linters#apex#apexlsp#Executable(a:buffer),
    \ '-cp '.ale_linters#apex#apexlsp#Jar(a:buffer),
    \ '-Xmx'.ale_linters#apex#apexlsp#JavaMem(a:buffer),
    \ '-XX:+UnlockExperimentalVMOptions',
    \ '-XX:+UseZGC',
    \ '-Ddebug.internal.errors=true',
    \ 'apex.jorje.lsp.ApexLanguageServerLauncher'
    \]

    return join(l:cmd,' ')
endfunction

call ale#linter#Define('apex', {
\   'name': 'apexlsp',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#apex#apexlsp#Executable'),
\   'command': function('ale_linters#apex#apexlsp#Command'),
\   'language': 'apex',
\   'project_root': function('ale#apex#FindProjectRoot')
\})
