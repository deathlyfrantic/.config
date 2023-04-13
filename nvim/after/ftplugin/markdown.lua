vim.opt_local.spell = true
vim.opt_local.wrapmargin = 0

local function preview_markdown(args)
  if vim.fn.executable("cmark") == 0 then
    vim.notify(
      "Unable to convert Markdown (cmark is not available).",
      vim.log.levels.ERROR
    )
    return
  end
  local filename = vim.api.nvim_buf_get_name(0)
  if #args.args > 0 then
    filename = args
  end
  local outfile = vim.fn.tempname() .. ".html"
  os.execute(
    string.format("cmark %s > %s; open -g %s", filename, outfile, outfile)
  )
end

vim.api.nvim_buf_create_user_command(
  0,
  "PreviewMarkdown",
  preview_markdown,
  { nargs = "?" }
)
