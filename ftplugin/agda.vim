if !exists('g:agda_started')
    function s:OnEvent(id, data, event) dict
        let l:msg = ''

        for l:line in a:data
            try
                let l:json = json_decode(l:line)
                let l:msg .= s:ParseJson(l:json)
            catch
            endtry
        endfor

        echo l:msg
    endfunction

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

function s:AgdaCompute() range
    let l:input = join(getline(a:firstline, a:lastline), '\\n')

    let l:input = substitute(l:input, '\', '\\\\', 'g')
    let l:input = substitute(l:input, '"', '\\"', 'g')

    let l:cmd = 'Cmd_compute_toplevel DefaultCompute "' . l:input . '"'

    call s:AgdaSendCommand(l:cmd)
endfunction

command! -buffer -nargs=0 AgdaLoad call s:AgdaLoad()
command! -buffer -range -nargs=0 AgdaCompute <line1>,<line2>call s:AgdaCompute()
