let mapleader=' '

augroup agda
  autocmd!

  " Normal mode bindings.
  autocmd Filetype agda nnoremap <buffer> <leader>l :write<cr>:AgdaLoad<cr>
  autocmd Filetype agda nnoremap <buffer> <leader>n :AgdaCompute<cr>
  autocmd Filetype agda nnoremap <buffer> <leader>t :AgdaInferType<cr>

  " Visual mode bindings.
  autocmd Filetype agda vnoremap <buffer> <leader>l <esc>:write<cr>:AgdaLoad<cr>gv
  autocmd Filetype agda vnoremap <buffer> <leader>n :AgdaComputeSelection<cr>
  autocmd Filetype agda vnoremap <buffer> <leader>t :AgdaInferTypeSelection<cr>
augroup END
