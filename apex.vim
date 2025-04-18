" Author: Suraj
" Description: Functions for integrating with Apex tools

" Find the nearest dir contining an sfdx-project.json file and assume it is
" the root of a sfdx app.
function! ale#apex#FindProjectRoot(buffer) abort

    let l:sfdx_project_file = ale#path#FindNearestFile(a:buffer, 'sfdx-project.json')

    if !empty(l:sfdx_project_file)
        return fnamemodify(l:sfdx_project_file, ':h')
    endif

    return ''
endfunction
