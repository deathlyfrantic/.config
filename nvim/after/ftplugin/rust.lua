vim.opt_local.commentstring = "// %s"
vim.opt_local.matchpairs:append("<:>")

local function populate_rustfmt_edition()
  local paths = vim.fs.find("Cargo.toml", {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    type = "file",
  })
  if #paths == 0 then
    return
  end
  local cargo_toml = io.open(paths[1])
  for line in cargo_toml:lines() do
    if line:trim():starts_with("edition") then
      local edition = line:split("=")[2]:match([["(.+)"]])
      if edition then
        vim.b.ale_rust_rustfmt_options = "--edition " .. edition
        break
      end
    end
  end
  io.close(cargo_toml)
end

if not vim.b.ale_rust_rustfmt_options then
  populate_rustfmt_edition()
end
