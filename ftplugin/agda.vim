if !exists('g:agda_started')
  " `OnEvent` and `ParseJson` functions deal with the output of the Agda
  " process. Dealing with the Agda process is extremely easy thanks to the
  " built-in function `json_decode` and Neovim's job control.

  " `stdout` callback for the Agda job.
  function s:OnEvent(id, data, event) dict
    let l:msg = ''

    for l:line in a:data
      if l:line =~ '^{.*}$'
        let l:json = json_decode(l:line)
        try
          let l:msg .= s:ParseJson(l:json)
        catch
          echo 'Error while parsing JSON: ' l:line . v:exception
        endtry
      endif
    endfor

    " For now all feedback is provided via echoes. Maybe opening an auxiliary
    " output buffer would be desirable, however this will not be implemented
    " unless I see the need and it doesn't make the plugin too complicated.
    echo l:msg
  endfunction

  " Only deals with `DisplayInfo` messages.
  function s:ParseJson(json)
    let l:msg = ''

    if a:json.kind == 'DisplayInfo'
      if a:json.info.kind == 'AllGoalsWarnings'
        if a:json.info.errors != []
          for l:error in a:json.info.errors
            let l:msg .= 'Error: ' . l:error.message . "\n"
          endfor
        else
          let l:msg .= "OK\n"
        endif

        if a:json.info.warnings != []
          for l:warning in a:json.info.warnings
            let l:msg .= 'Warning: ' . l:warning.message . "\n"
          endfor
        endif

        let l:length = len(a:json.info.visibleGoals)
        if l:length > 0
          let l:msg .= l:length == 1 ? "Goal:\n" : "Goals:\n"
          for l:goal in a:json.info.visibleGoals
            let l:msg .= l:goal.constraintObj.id . ': ' . l:goal.type . ' (Kind: ' . l:goal.kind . ")\n"
          endfor
        endif

      elseif a:json.info.kind == 'Error'
        let l:msg .= 'Error: ' . a:json.info.error.message . "\n"

      elseif a:json.info.kind == 'InferredType'
        let l:msg .= 'Inferred Type: ' . a:json.info.expr . "\n"

      elseif a:json.info.kind == 'NormalForm'
        let l:msg .= 'Normal Form: ' . a:json.info.expr . "\n"
      endif

      " TODO: check API for all possible outcomes and add them to the output
      " list.
    endif

    return l:msg
  endfunction

  " The user is not supposed directly interact with `agda_job` nor
  " `agda_started`. `agda_job` is defined as a global variable to permit only
  " one Agda instance for multiple Agda files.
  let g:agda_job = jobstart(['agda', '--interaction-json'], {
        \   'on_stdout': function('s:OnEvent'),
        \ })

  let g:agda_started = 1
endif

if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

let b:undo_ftplugin = 'setlocal comments< commentstring< |'

setlocal comments=s1fl:{-,mb:-,ex:-},:--
setlocal commentstring=--\ %s
" See `:h fo-table`.
setlocal formatoptions-=t
setlocal formatoptions+=croql

function s:AgdaSendCommand(cmd)
  " Full path of current file.
  let l:name = expand('%:p')

  "
  "   data IOTCM = IOTCM
  "     FilePath            -- Always the current file.
  "     HighlightingLevel   -- `None` as this plugin does not and will not
  "                         -- support highlighting.
  "     HighlightingMethod  -- Irrelevant.
  "     Interaction
  "
  let l:cmd = 'IOTCM "' . l:name . '" None Direct (' . a:cmd . ')'

  call chansend(g:agda_job, l:cmd . "\n")
endfunction

function s:AgdaLoad()
  " Full path of current file.
  let l:name = expand('%:p')

  "
  "   data Interaction
  "     = Cmd_load FilePath [String]
  "     ...
  "
  " Loads `l:name` without passing any command-line options.
  let l:cmd = 'Cmd_load "' . l:name . '" []'

  call s:AgdaSendCommand(l:cmd)
endfunction

function s:EscapeString(str)
  let l:str = substitute(a:str, '\', '\\\\', 'g')
  let l:str = substitute(l:str, '"', '\\"', 'g')

  return l:str
endfunction

" Gets text selected in Visual mode and returns it as a list of lines.
function s:GetVisualSelection()
  try
    let l:a = @a
    " gv    Visual reselect.
    " "ay   Yank into register `a`.
    normal! gv"ay
    return split(@a, "\n")
  finally
    let @a = l:a
  endtry
endfunction

function s:AgdaCompute()
  call inputsave()

  let l:input = s:EscapeString(input('Expression: '))
  " TODO: check whether the input is empty or not.

  call inputrestore()

  "
  "   data Interaction
  "     ...
  "     | Cmd_compute ComputeMode String
  "     ...
  "
  " Type-check and normalize the given expression.
  let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:input . '"'

  call s:AgdaSendCommand(l:cmd)
endfunction

function s:AgdaComputeSelection()
  let l:input = s:GetVisualSelection()

  for l:line in l:input
    let l:line = s:EscapeString(l:line)

    let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:line . '"'

    call s:AgdaSendCommand(l:cmd)
  endfor
endfunction

function s:AgdaInferType()
  call inputsave()

  let l:input = s:EscapeString(input('Expression: '))

  call inputrestore()

  "
  "   data Interaction
  "     ...
  "     | Cmd_infer_toplevel ComputeMode String
  "     ...
  "
  " Parse the given expression and infer its type.
  let l:cmd = 'Cmd_infer_toplevel AsIs "' . l:input . '"'

  call s:AgdaSendCommand(l:cmd)
endfunction

function s:AgdaInferTypeSelection()
  let l:input = s:GetVisualSelection()

  for l:line in l:input
    let l:line = s:EscapeString(l:line)

    let l:cmd = 'Cmd_infer_toplevel AsIs "' . l:line . '"'

    call s:AgdaSendCommand(l:cmd)
  endfor
endfunction

let b:undo_ftplugin .= 'delcommand AgdaLoad |'
let b:undo_ftplugin .= 'delcommand AgdaCompute |'
let b:undo_ftplugin .= 'delcommand AgdaComputeSelection |'
let b:undo_ftplugin .= 'delcommand AgdaInferType |'
let b:undo_ftplugin .= 'delcommand AgdaInferTypeSelection'

" This is all the interface that Magda exposes.
command -buffer -nargs=0 AgdaLoad call s:AgdaLoad()
command -buffer -nargs=0 AgdaCompute call s:AgdaCompute()
command -buffer -range -nargs=0 AgdaComputeSelection call s:AgdaComputeSelection()
command -buffer -nargs=0 AgdaInferType call s:AgdaInferType()
command -buffer -range -nargs=0 AgdaInferTypeSelection call s:AgdaInferTypeSelection()

let &cpo = s:cpo_save
unlet s:cpo_save
