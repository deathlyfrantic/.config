local function dot_to_png(...)
  if vim.fn.executable("dot") == 0 then
    vim.api.nvim_err_writeln("Graphviz/Dot is not available.")
    return
  end
  local filename = vim.fn.expand("%:p")
  if select("#", ...) > 0 then
    filename = ...
  end
  local outfile = vim.fn.fnamemodify(filename, ":r") .. ".png"
  os.execute(string.format("dot %s -Tpng > %s", filename, outfile))
end

_G.graphviz_dot = { dot_to_png = dot_to_png }

vim.cmd("command! -buffer -nargs=? DotToPng call v:lua.graphviz_dot.dot_to_png(<args>)")
