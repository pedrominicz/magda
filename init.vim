let maplocalleader = ' '

augroup agda
  autocmd!

  " Normal mode bindings.
  autocmd Filetype agda nnoremap <buffer> <localleader>al <cmd>write<cr><cmd>AgdaLoad<cr>
  autocmd Filetype agda nnoremap <buffer> <localleader>an <cmd>AgdaCompute<cr>
  autocmd Filetype agda nnoremap <buffer> <localleader>at <cmd>AgdaInferType<cr>

  " Visual mode bindings.
  autocmd Filetype agda vnoremap <buffer> <localleader>al <cmd>write<cr><cmd>AgdaLoad<cr>
  autocmd Filetype agda vnoremap <buffer> <localleader>an <cmd>AgdaComputeSelection<cr>
  autocmd Filetype agda vnoremap <buffer> <localleader>at <cmd>AgdaInferTypeSelection<cr>
augroup END
