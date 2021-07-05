local api = vim.api
local z = require("z")

local packager_initialized = false
local packages = {}
local lazy = {
  ft = {},
  on_cmd = {},
  on_map = {},
}

local function expand(path)
  return vim.fn.expand(path)
end

local function isdirectory(path)
  return vim.fn.isdirectory(path) == 1
end

local function add_package(bang, path, opts)
  opts = opts or {}
  if bang == "!" then
    packager_initialized = false
  end
  local name = vim.fn.fnamemodify(path, ":t")
  if opts["for"] ~= nil then
    opts.type = "opt"
    for _, ft in pairs(z.to_array(opts["for"])) do
      if lazy.ft[ft] == nil then
        lazy.ft[ft] = {}
      end
      table.insert(lazy.ft[ft], name)
    end
  end
  if opts.on ~= nil then
    opts.type = "opt"
    for _, on in pairs(z.to_array(opts.on)) do
      if on:match("^<Plug>") ~= nil then
        lazy.on_map[on] = name
      else
        lazy.on_cmd[on] = name
      end
    end
  end
  table.insert(packages, { path, opts })
end

local function _pkg_cmd(cmd, name, bang, line1, line2, range, args)
  vim.cmd("silent! delcommand " .. cmd)
  vim.cmd("packadd " .. name)
  if range > 0 then
    vim.cmd(line1 .. "," .. line2 .. cmd .. bang .. " " .. args)
  else
    vim.cmd(cmd .. bang .. " " .. args)
  end
end

local function _pkg_map(map, name, visual)
  api.nvimdel_keymap("n", map)
  api.nvim_del_keymap("x", map)
  vim.cmd("packadd " .. name)
  if visual then
    api.nvim_feedkeys("gv", "n")
  end
  api.nvim_feedkeys(api.nvim_replace_termcodes(map, true, false, true))
end

local function packager_init()
  if packager_initialized then
    return
  end
  packager_initialized = true
  vim.cmd("packadd vim-packager")
  vim.fn["packager#init"]()
  for _, p in pairs(packages) do
    local name, opts = p[1], p[2]
    if next(opts) == nil then
      opts = { type = "start" }
    end
    local fn = "add"
    if isdirectory(expand(name)) then
      fn = "local"
    end
    vim.fn["packager#" .. fn](name, opts)
  end
end

local function _from_viml_add_pkg(args)
  local bang, name, opts = args[1], args[2], {}
  if #args > 2 then
    if type(args[3]) ~= "table" then
      return api.nvim_err_writeln("Second argument must be a table.")
    else
      opts = args[3]
    end
  end
  return add_package(bang, name, opts)
end

local function _packager_cmd(fn)
  packager_init()
  vim.fn["packager#" .. fn]()
end

local function init()
  vim.cmd([[command! -bang -nargs=+ Package call luaeval('require("packages")._from_viml_add_pkg(_A)', [<q-bang>, <args>])]])
  for _, name in pairs({ "clean", "install", "status", "update" }) do
    local cmd = "Pack" .. name:sub(1, 1):upper() .. name:sub(2)
    vim.cmd(([[command! %s lua require("packages")._packager_cmd("%s")]]):format(cmd, name))
  end
  vim.cmd("source $VIMHOME/packages.vim")
  vim.cmd("augroup packager-filetypes")
  vim.cmd("autocmd!")
  for ft, pkgs in pairs(lazy.ft) do
    for _, pkg in pairs(pkgs) do
      vim.cmd("autocmd FileType " .. ft .. " ++once packadd " .. pkg)
    end
    vim.cmd(
      "autocmd FileType " .. ft .. " ++once ++nested doautocmd FileType"
    )
  end
  vim.cmd("augroup END")
  for cmd, pkg in pairs(lazy.on_cmd) do
    vim.cmd(([[command! -range -bang -bar -nargs=* %s lua require("packages")_.pkg_cmd("%s", "%s", <q-bang>, <line1>, <line2>, <range>, <q-args>)]]):format(cmd, cmd, pkg))
  end
  for map, pkg in pairs(lazy.on_map) do
    api.nvim_set_keymap(
      "n",
      map,
      string.format(
        [[:call luaeval('require("packages")._pkg_map("%s", "%s", false)')<CR>]],
        map,
        pkg
      ),
      { silent = true }
    )
    api.nvim_set_keymap(
      "x",
      map,
      string.format(
        [[:call luaeval('require("packages")._pkg_map("%s", "%s", true)')<CR>]],
        map,
        pkg
      ),
      { silent = true }
    )
  end
end

return {
  _from_viml_add_pkg = _from_viml_add_pkg,
  add_package = add_package,
  init = init,
  _pkg_cmd = _pkg_cmd,
  _pkg_map = _pkg_map,
  _packager_cmd = _packager_cmd,
}
