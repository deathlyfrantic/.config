execute 'source' expand('<sfile>:h') .. '/javascript.vim'

let b:neoformat_enabled_javascriptreact = b:neoformat_enabled_javascript

for formatter in b:neoformat_enabled_javascript
  let b:neoformat_javascriptreact_{formatter} =
        \ get(b:, 'neoformat_javascript_' .. formatter,
        \ neoformat#formatters#javascript#{formatter}())
endfor
