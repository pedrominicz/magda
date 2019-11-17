let mapleader=' '

augroup agda
    autocmd!
    autocmd Filetype agda nnoremap <buffer> <leader>r :wall<cr>:AgdaLoad<cr>
    autocmd Filetype agda nnoremap <buffer> <leader>n :AgdaCompute<cr>
    autocmd Filetype agda vnoremap <buffer> <leader>n :AgdaCompute<cr>
augroup END
