if !exists('g:agda_started')
    function s:OnEvent(id, data, event) dict
        if a:event == 'stdout'
            echo join(a:data, "\n")
        endif
    endfunction

    let g:agda_job = jobstart(['agda', '--interaction'], {
                \   'on_stdout': function('s:OnEvent'),
                \ })

    let g:agda_started = 1
endif

function s:AgdaSendCommand()
    let l:name = expand('%:p')

    let l:cmd = 'IOTCM "' . l:name . '" None Direct (Cmd_load "' . l:name . '" [])'

    call chansend(g:agda_job, l:cmd . "\n")
endfunction

function s:AgdaLoad()
    call s:AgdaSendCommand()
endfunction

nnoremap <buffer> <localleader>l :call <sid>AgdaLoad()<cr>
nnoremap <buffer> <localleader>n :call <sid>AgdaLoad()<cr>
