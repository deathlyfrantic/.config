function! snippetcomplete#complete(findstart, base) abort
    if a:findstart
        return completion#findstart()
    endif
    let l:snippets = UltiSnips#SnippetsInCurrentScope()
    let l:keys = filter(sort(keys(l:snippets)), 'substitute(v:val, "^alias ", "", "") =~? a:base')
    return map(copy(l:keys), '{"word": v:val, "menu": l:snippets[v:val]}')
endfunction
