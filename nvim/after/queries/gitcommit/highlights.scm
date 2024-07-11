; extends

(ERROR) @gitcommit_error

((subject) @gitcommit_error
  (#vim-match? @gitcommit_error ".\{50,}")
  (#offset! @gitcommit_error 0 50 0 0))

((message_line) @gitcommit_error
  (#vim-match? @gitcommit_error ".\{72,}")
  (#offset! @gitcommit_error 0 72 0 0))
