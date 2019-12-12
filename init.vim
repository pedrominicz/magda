let mapleader=' '

augroup agda
    autocmd!

    " Normal mode bindings.
    autocmd Filetype agda nnoremap <buffer> <leader>l :write<cr>:AgdaLoad<cr>
    autocmd Filetype agda nnoremap <buffer> <leader>n :AgdaCompute<cr>

    " Visual mode bindings.
    autocmd Filetype agda vnoremap <buffer> <leader>l :write<cr>:AgdaLoad<cr>
    autocmd Filetype agda vnoremap <buffer> <leader>n :AgdaComputeSelection<cr>
augroup END