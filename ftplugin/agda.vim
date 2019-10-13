if !exists('g:agda_started')
    nnoremap <buffer> <leader>g :echo 'First Agda file.'<cr>

    function s:OnEvent(id, data, event) dict
        if a:event == 'stdout'
            let msg = 'Agda started successfully.'
        endif

        call append(line('$'), msg)
    endfunction

    let g:agda_job = jobstart(['agda', '--interaction-json'], {
                \   'on_stdout': function('s:OnEvent'),
                \ })

    let g:agda_started = 1

    finish
endif

nnoremap <buffer> <leader>g :echo 'Agda file.'<cr>
