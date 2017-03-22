function! emailcomplete#complete(findstart, base) abort
    if a:findstart
        let l:line = getline(".")
        let l:col = col(".")
        while l:line[l:col] !~? "\s" && l:col >= 0
            let l:col -= 1
        endwhile
        return l:col + 1
    endif
    let l:aliases = readfile(expand("$XDG_CONFIG_HOME/mutt/aliases.muttrc"))
    let l:emails = filter(l:aliases, 'substitute(v:val, "^alias ", "", "") =~? a:base')
    return map(copy(l:emails), 'substitute(v:val, "^alias \\w\\+ ", "", "")')
endfunction
