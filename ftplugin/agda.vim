if !exists('g:agda_started')
    nnoremap <buffer> <leader>g :echo "First Agda file."<cr>

    let g:agda_started = 1

    finish
endif

nnoremap <buffer> <leader>g :echo "Agda file."<cr>
