if !exists('g:agda_started')
    function s:OnEvent(id, data, event) dict
        if a:event == 'stdout'
            call append(line('$'), a:data)
        elseif a:event == 'stderr'
            call append(line('$'), a:data)
        endif
    endfunction

    let g:agda_job = jobstart(['agda', '--interaction-json'], {
                \   'on_stdout': function('s:OnEvent'),
                \   'on_stderr': function('s:OnEvent'),
                \ })

    let g:agda_started = 1
endif

function s:AgdaLoad()
    call chansend(g:agda_job, "IOTCM \"Test.agda\" None Direct (Cmd_load \"Test.agda\" [])\n")
endfunction

nnoremap <buffer> <localleader>l :call <sid>AgdaLoad()<cr>
