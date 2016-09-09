set __fish_git_prompt_show_informative_status 1

set __fish_git_prompt_color_branch -o 'black'

set __fish_git_prompt_char_dirtystate '+'
set __fish_git_prompt_color_dirtystate -o 'blue'

set __fish_git_prompt_char_upstream_ahead '>'
set __fish_git_prompt_char_upstream_behind '<'
set __fish_git_prompt_color_upstream -o 'cyan'

set __fish_git_prompt_char_cleanstate '='
set __fish_git_prompt_color_cleanstate -o 'green'

set __fish_git_prompt_char_stagedstate '-'
set __fish_git_prompt_color_stagedstate -o 'yellow'

set __fish_git_prompt_char_untrackedfiles '_'
set __fish_git_prompt_color_untrackedfiles -o 'magenta'

set __fish_git_prompt_char_invalidstate '!'
set __fish_git_prompt_color_invalidstate -o 'red'

function fish_right_prompt
    set __fgpr (__fish_git_prompt)
    if test $__fgpr
        set __fgpr (string replace '(' '[' $__fgpr)
        set __fgpr (string replace ')' ']' $__fgpr)
        printf $__fgpr
    end
end
