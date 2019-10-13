if !exists('g:agda_started')
    function s:OnEvent(id, data, event) dict
        let l:msg = ''

        for l:line in a:data
            try
                let l:json = json_decode(l:line)

                if l:json.kind == 'DisplayInfo'
                    if l:json.info.kind == 'AllGoalsWarnings'
                        if l:json.info.errors != ''
                            let l:msg .= "\n--- ERROR ---\n"
                            let l:msg .= l:json.info.errors
                        else
                            let l:msg .= "OK"
                        endif

                        if l:json.info.warnings != ''
                            let l:msg .= "\n--- WARNING ---\n"
                            let l:msg .= l:json.info.warnings
                        endif

                        if l:json.info.goals != ''
                            let l:msg .= "\n--- GOAL ---\n"
                            let l:msg .= l:json.info.goals
                        endif

                    elseif l:json.info.kind == 'Error'
                        let l:msg .= "\n--- ERROR ---\n"
                        let l:msg .= l:json.info.payload

                    elseif l:json.info.kind == 'NormalForm'
                        let l:msg .= l:json.info.payload . "\n"
                    endif
                endif
            catch
            endtry
        endfor

        echo l:msg
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

function s:AgdaSendCommand(cmd)
    let l:name = expand('%:p')

    let l:cmd = 'IOTCM "' . l:name . '" None Direct (' . a:cmd . ')'

    call chansend(g:agda_job, l:cmd . "\n")
endfunction

function s:AgdaLoad()
    let l:name = expand('%:p')

    let l:cmd = '(Cmd_load "' . l:name . '" [])'

    call s:AgdaSendCommand(l:cmd)
endfunction

function s:AgdaCompute()
    call inputsave()

    let l:input = input('Expression: ')

    call inputrestore()

    let l:input = substitute(l:input, '\', '\\\\', 'g')
    let l:input = substitute(l:input, '"', '\\"', 'g')
    let l:input = substitute(l:input, "\n", '\\n', 'g')

    let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:input . '"'

    call s:AgdaSendCommand(l:cmd)
endfunction

command! -buffer -nargs=0 AgdaLoad call s:AgdaLoad()
command! -buffer -nargs=0 AgdaCompute call s:AgdaCompute()
