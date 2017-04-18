function! completion#findstart() abort
    let l:curpos = getcurpos()
    let l:pos = searchpos('\s', 'b')
    return (l:pos[0] == l:curpos[1]) ? l:pos[1] : 0
endfunction
