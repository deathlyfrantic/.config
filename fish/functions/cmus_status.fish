# this doesn't work because cmus doesn't use fish as the shell :(
function cmus_status
    for i in (seq (count $argv))
        if [ (math "$i % 2") != 0 ]
            set _$argv[$i] $argv[(math $i + 1)]
        end
    end

    echo $_artist
    echo $_title
    echo $_status

    if [ $_status = "stopped" ]
        set _remove "--remove"
    else if [ $_status = "playing" ]
        set __status ""
    else
        set __status " [$_status]"
    end

    set _output (escape_for_pango "$_artist - $_title$__status")
    ~/Code/swaystag/swaystag.py block --name "music" --sort_order 1 --full_text "$_output" --short_text "$_title" $_remove
end
