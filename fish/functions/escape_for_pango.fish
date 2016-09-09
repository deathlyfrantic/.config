function escape_for_pango
    set _pango_search '&' '>' '<' "'" '"'
    set _pango_replace '&amp;' '&gt;' '&lt;' '&apos;' '&quot;'
    for x in $argv
        set _x $x
        for i in (seq (count $_pango_search))
            set _x (string replace $_pango_search[$i] $_pango_replace[$i] $_x -a)
        end
        printf "$_x "
    end
    printf "\n"
end
