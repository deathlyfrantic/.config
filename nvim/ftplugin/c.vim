let b:code_dir = expand('~').'/Code/'
let b:file_dir = fnamemodify(expand('%'), ':p:h')
let b:path_chunks = split(substitute(b:file_dir, b:code_dir, '', ''), '/')
let b:project_dir = b:path_chunks[0]
let b:include_dir = b:code_dir . b:project_dir . '/include/'

let b:neomake_c_clang_args = ['-fsyntax-only', '-Wall', '-Wextra', '-I'.b:include_dir]
let b:neomake_c_enabled_makers = ['clang']
