local function dot_to_png(args)
  if vim.fn.executable("dot") == 0 then
    vim.api.nvim_err_writeln("Graphviz/Dot is not available.")
    return
  end
  local filename = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if #args.args > 0 then
    filename = args.args
  end
  local outfile = vim.fn.fnamemodify(filename, ":r") .. ".png"
  os.execute(string.format("dot %s -Tpng > %s", filename, outfile))
end

vim.api.nvim_buf_create_user_command(0, "DotToPng", dot_to_png, { nargs = "?" })
