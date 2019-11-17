if !exists('g:agda_started')
    " `OnEvent` and `ParseJson` functions deal with the output of the Agda
    " process. Dealing with JSON is extremely easy thanks to Neovim's built-in
    " function `json_decode`.
    function s:OnEvent(id, data, event) dict
        let l:msg = ''

        for l:line in a:data
            try
                let l:json = json_decode(l:line)
                let l:msg .= s:ParseJson(l:json)
            catch
            endtry
        endfor

        " For now all feedback is provided via echoes. Maybe opening an
        " auxiliary output buffer would be desirable, however this will not be
        " implemented unless I see the need and it doesn't make the plugin too
        " complicated.
        echo l:msg
    endfunction

    " Only deals with `DisplayInfo` messages.
    function s:ParseJson(json)
        let l:msg = ''

        if a:json.kind == 'DisplayInfo'
            if a:json.info.kind == 'AllGoalsWarnings'
                if a:json.info.errors != ''
                    let l:msg .= "\n--- ERROR ---\n"
                    let l:msg .= a:json.info.errors
                else
                    let l:msg .= "OK\n"
                endif

                if a:json.info.warnings != ''
                    let l:msg .= "\n--- WARNING ---\n"
                    let l:msg .= a:json.info.warnings
                endif

                if a:json.info.goals != ''
                    let l:msg .= "\n--- GOAL ---\n"
                    let l:msg .= a:json.info.goals
                endif

            elseif a:json.info.kind == 'Error'
                let l:msg .= "\n--- ERROR ---\n"
                let l:msg .= a:json.info.payload

            elseif a:json.info.kind == 'NormalForm'
                let l:msg .= a:json.info.payload . "\n"
            endif
        endif

        return l:msg
    endfunction

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

let b:undo_ftplugin = 'setlocal comments< commentstring<'

setlocal comments=s1fl:{-,mb:-,ex:-},:--
setlocal commentstring=--\ %s
" See `:h fo-table`.
setlocal formatoptions-=t
setlocal formatoptions+=croql

let &cpo = s:cpo_save
unlet s:cpo_save

function s:AgdaSendCommand(cmd)
    " Full path of current file.
    let l:name = expand('%:p')

    "
    "   data IOTCM = IOTCM
    "       FilePath            -- Always the current file.
    "       HighlightingLevel   -- `None` as this plugin does not and will not
    "                           -- support highlighting.
    "       HighlightingMethod  -- Irrelevant.
    "       Interaction
    "
    let l:cmd = 'IOTCM "' . l:name . '" None Direct (' . a:cmd . ')'

    call chansend(g:agda_job, l:cmd . "\n")
endfunction

function s:AgdaLoad()
    " Full path of current file.
    let l:name = expand('%:p')

    "
    "   data Interaction
    "       = Cmd_load FilePath [String]
    "       ...
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

function s:AgdaCompute()
    call inputsave()

    let l:input = s:EscapeString(input('Expression: '))

    call inputrestore()

    "
    "   data Interaction
    "       ...
    "       | Cmd_compute ComputeMode String
    "       ...
    "
    " Type-check and normalize the given expression.
    let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:input . '"'

    call s:AgdaSendCommand(l:cmd)
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

function s:AgdaComputeSelection()
    let l:input = s:GetVisualSelection()

    for l:line in l:input
        let l:line = s:EscapeString(l:line)

        let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:line . '"'

        call s:AgdaSendCommand(l:cmd)
    endfor
endfunction

command! -buffer -nargs=0 AgdaLoad call s:AgdaLoad()
command! -buffer -nargs=0 AgdaCompute call s:AgdaCompute()
command! -buffer -range -nargs=0 AgdaComputeSelection call s:AgdaComputeSelection()
