function fish_prompt
    set pieces (string split "/" (prompt_pwd))
    for i in $pieces
        set_color normal
        printf $i
        set_color brgrey
        if [ $i = $pieces[-1] ]
            printf ": "
        else
            printf "/"
        end
    end
    set_color normal
end
