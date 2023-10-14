local function dot_to_png(args)
  if vim.fn.executable("dot") == 0 then
    vim.notify("Graphviz/Dot is not available.", vim.log.levels.ERROR)
    return
  end
  local filename = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if #args.args > 0 then
    filename = args.args
  end
  local outfile = filename:match("(.*)%.") .. ".png"
  os.execute(("dot %s -Tpng > %s"):format(filename, outfile))
end

vim.api.nvim_buf_create_user_command(0, "DotToPng", dot_to_png, { nargs = "?" })
