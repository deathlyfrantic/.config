vim.opt_local.cinoptions:append({ "l1" })
vim.opt_local.commentstring = "// %s"
-- overrides default arrow function behavior from init.lua
vim.keymap.set("i", "<C-j>", "->", { buffer = true })

local headers = {
  "assert",
  "ctype",
  "inttypes",
  "limits",
  "signal",
  "stdbool",
  "stdint",
  "stdio",
  "stdlib",
  "string",
  "time",
  "unistd",
}

local nested_headers = { systypes = "sys/types" }

for _, h in ipairs(headers) do
  vim.keymap.set(
    "ia",
    h .. "h",
    ("#include <%s.h>"):format(h),
    { buffer = true }
  )
end

for h, f in pairs(nested_headers) do
  vim.keymap.set(
    "ia",
    h .. "h",
    ("#include <%s.h>"):format(f),
    { buffer = true }
  )
end

if
  vim.api.nvim_buf_get_name(0):ends_with(".h")
  and vim.api.nvim_buf_line_count(0) == 1
  and vim.api.nvim_buf_get_lines(0, 0, 1, true)[1] == ""
then
  local guard = ("%s_%s"):format(
    vim.fs.basename(vim.uv.cwd()):upper(),
    vim.fs.basename(vim.api.nvim_buf_get_name(0)):upper():gsub("[^A-Z0-9]", "_")
  )
  local new_lines = {
    "#ifndef " .. guard,
    "#define " .. guard,
    "",
    "",
    "",
    "#endif /* end of include guard: " .. guard .. "*/",
  }
  vim.api.nvim_buf_set_lines(0, 0, 1, true, new_lines)
  vim.api.nvim_win_set_cursor(0, { 4, 1 })
end
