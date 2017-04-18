function! emailcomplete#complete(findstart, base) abort
    if a:findstart
        return completion#findstart()
    endif
    let l:aliases = readfile(expand('$XDG_CONFIG_HOME/mutt/aliases.muttrc'))
    let l:emails = filter(l:aliases, 'substitute(v:val, "^alias ", "", "") =~? a:base')
    return map(copy(l:emails), 'substitute(v:val, "^alias \\w\\+ ", "", "")')
endfunction
