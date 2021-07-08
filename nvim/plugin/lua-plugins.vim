let s:plugins = [
      \ 'autoclose',
      \ 'commandline',
      \ 'dirvish-extras',
      \ 'packages',
      \ 'qf-preview',
      \ 'star',
      \ ]
for plugin in s:plugins
  exec 'lua require("' .. plugin .. '").init()'
endfor
