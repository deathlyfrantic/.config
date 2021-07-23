vim.opt_local.spell = true
vim.opt_local.wrapmargin = 0

local function preview_markdown(...)
  if vim.fn.executable("cmark") == 0 then
    vim.api.nvim_err_writeln("Unable to convert Markdown (cmark is not available).")
    return
  end
  local filename = vim.fn.expand("%:p")
  if select("#", ...) > 0 then
    filename = ...
  end
  local outfile = vim.fn.tempname() .. ".html"
  os.execute(string.format("cmark %s > %s; open -g %s", filename, outfile, outfile))
end

_G.markdown = { preview = preview_markdown }

vim.cmd("command! -buffer -nargs=? PreviewMarkdown call v:lua.markdown.preview(<args>)")
