let s:plugins = [
      \ 'autoclose',
      \ 'dirvish-extras',
      \ 'packages',
      \ 'qf-preview'
      \ ]
for plugin in s:plugins
  exec 'lua require("' .. plugin .. '").init()'
endfor
