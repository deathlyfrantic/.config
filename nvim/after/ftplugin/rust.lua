local function populate_rustfmt_edition()
  local cargo_toml_path = vim.fn.findfile("Cargo.toml", ".;")
  if cargo_toml_path == "" then
    return
  end
  local cargo_toml = io.open(cargo_toml_path)
  for line in cargo_toml:lines() do
    if line:trim():starts_with("edition") then
      local edition =
        line:split("=", { plain = true, trimempty = true })[2]:match([["(.+)"]])
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
