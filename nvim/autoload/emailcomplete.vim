function! emailcomplete#complete(findstart, base) abort
    if a:findstart
        let l:curpos = getcurpos()
        let l:pos = searchpos('\s', 'b')
        return (l:pos[0] == l:curpos[1]) ? l:pos[1] : 0
    endif
    let l:aliases = readfile(expand('$XDG_CONFIG_HOME/mutt/aliases.muttrc'))
    let l:emails = filter(l:aliases, 'substitute(v:val, "^alias ", "", "") =~? a:base')
    return map(copy(l:emails), 'substitute(v:val, "^alias \\w\\+ ", "", "")')
endfunction
