local api = vim.api

local packer_path = vim.fn.stdpath("config")
  .. "/pack/packer/start/packer.nvim"

local need_to_compile = false

if vim.fn.isdirectory(packer_path) ~= 1 then
  os.execute("git clone github:wbthomason/packer.nvim " .. packer_path)
  vim.api.nvim_echo({ { "Installed packer.nvim", "WarningMsg" } }, false, {})
  need_to_compile = true
end

local packer = require("packer")
local use = packer.use

packer.init({
  package_root = vim.fn.stdpath("config") .. "/pack",
  display = { working_sym = "…" },
})

use("wbthomason/packer.nvim")

use({ "rust-lang/rust.vim", ft = "rust" })
use({ "cespare/vim-toml", ft = "toml" })
use({ "pangloss/vim-javascript", ft = "javascript" })

use("Julian/vim-textobj-variable-segment")
use("kana/vim-textobj-user")
use("michaeljsmith/vim-indent-object")
use("glts/vim-textobj-comment")
use("~/src/vim/textobj-blanklines")

use({
  "airblade/vim-gitgutter",
  config = function()
    vim.api.nvim_set_keymap("o", "ig", "<Plug>(GitGutterTextObjectInnerPending)", {})
    vim.api.nvim_set_keymap("o", "ag", "<Plug>(GitGutterTextObjectOuterPending)", {})
    vim.api.nvim_set_keymap("x", "ig", "<Plug>(GitGutterTextObjectInnerVisual)", {})
    vim.api.nvim_set_keymap("x", "ag", "<Plug>(GitGutterTextObjectOuterVisual)", {})
    require("autocmd").augroup("packer-gitgutter-config", function(add)
      add("BufEnter,TextChanged,InsertLeave,BufWritePost", "*", function()
        vim.cmd("GitGutter")
      end)
      add("BufDelete", "*/.git/COMMIT_EDITMSG", function()
        vim.cmd("GitGutterAll")
      end)
    end)
  end,
})

use({
  "dense-analysis/ale",
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "[a",
      "<Cmd>ALEPreviousWrap<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "]a",
      "<Cmd>ALENextWrap<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap("n", "Q", "<Cmd>ALEDetail<CR>", { noremap = true })
    require("autocmd").augroup("packer-ale-config", function(add)
      add("FileType", "ale-preview", function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.colorcolumn = "0"
      end)
      add("FileType", "ale-preview.message", function()
        vim.opt_local.colorcolumn = "0"
      end)
      add("FileType", "rust,typescript", function()
        vim.bo.omnifunc = "ale#completion#OmniFunc"
        vim.api.nvim_buf_set_keymap(0, "n", "gd", "<Plug>(ale_go_to_definition)", {})
        vim.api.nvim_buf_set_keymap(0, "n", "K", "<Plug>(ale_hover)", {})
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "<C-w>i",
          "<Plug>(ale_go_to_definition_in_split)",
          {}
        )
      end)
    end)
    vim.g.ale_hover_to_floating_preview = 1
    vim.g.ale_floating_window_border = { " ", " ", " ", " ", " ", " " }
    vim.g.ale_fixers = {
      ["*"] = { "remove_trailing_lines", "trim_whitespace" },
      rust = { "rustfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "jq" },
      lua = { "stylua" },
    }
    vim.g.ale_fix_on_save = 1
    vim.g.ale_fix_on_save_ignore = { mail = { "trim_whitespace" } }
    vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy")
    if vim.fn.executable("rust-analyzer") then
      vim.g.ale_linters = { rust = { "analyzer", "cargo" } }
    end
    vim.g.ale_c_clang_options = "-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror"
    vim.g.ale_lua_stylua_options = "--config-path "
      .. vim.fn.stdpath("config")
      .. "/stylua.toml"
  end,
})

use({
  "junegunn/goyo.vim",
  cmd = "Goyo",
  config = function()
    vim.g.goyo_height = "96%"
    vim.g.goyo_width = 82
    local autocmd_handle
    require("autocmd").augroup("packer-goyo-config", function(add)
      add("User", "GoyoEnter", function()
        vim.o.showmode = false
        vim.o.showcmd = false
        vim.o.showtabline = 0
        autocmd_handle = require("autocmd").add("CursorHold,CursorHoldI", "*", function()
            vim.api.nvim_echo({}, false, {})
          end, { augroup = "goyo-cursorhold-clear", unique = true })
      end, { nested = true })
      add("User", "GoyoLeave", function()
        vim.o.showmode = true
        vim.o.showcmd = true
        vim.fn["buftabline#update"](0)
        require("autocmd").del(autocmd_handle)
      end, { nested = true })
    end)
  end,
})

use({
  "justinmk/vim-dirvish",
  config = function()
    vim.g.dirvish_mode = ":sort ,^.*[/],"
    vim.api.nvim_set_keymap("n", "-", "<Plug>(dirvish-toggle)", {})
  end,
})

use({
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SetFocusWhenToggle = 1
    api.nvim_set_keymap(
      "n",
      "<C-q>",
      "<Cmd>UndotreeToggle<CR>",
      { noremap = true, silent = true }
    )
  end,
})

use({
  "preservim/tagbar",
  cmd = "TagbarToggle",
  config = function()
    vim.g.tagbar_autofocus = 1
    vim.g.tagbar_iconchars = { "+", "-" }
    api.nvim_set_keymap(
      "n",
      "<C-t>",
      "<Cmd>TagbarToggle<CR>",
      { noremap = true, silent = true }
    )
  end,
})

use({
  "ap/vim-buftabline",
  config = function()
    vim.g.buftabline_show = 1
    vim.g.buftabline_indicators = 1
    vim.g.buftabline_numbers = 2
    local keys = "1234567890qwertyuiop"
    vim.g.buftabline_plug_max = #keys
    for i, k in keys:chars() do
      vim.api.nvim_set_keymap(
        "n",
        "<M-" .. k .. ">",
        "<Plug>BufTabLine.Go(" .. i .. ")",
        { silent = true }
      )
    end
  end,
})

use({
  "wellle/tmux-complete.vim",
  config = function()
    vim.g["tmuxcomplete#trigger"] = ""
    vim.api.nvim_set_keymap(
      "i",
      "<C-x><C-t>",
      "<Cmd>call completion#wrap('tmuxcomplete#complete')<CR>",
      { noremap = true }
    )
  end,
})

use("nelstrom/vim-visual-star-search")
use("tommcdo/vim-exchange")
use({
  "tommcdo/vim-lion",
  config = function()
    vim.g.lion_squeeze_spaces = 1
  end,
})

use("tpope/vim-abolish")
use("tpope/vim-apathy")
use("tpope/vim-endwise")
use("tpope/vim-obsession")
use("tpope/vim-repeat")
use("tpope/vim-scriptease")
use("tpope/vim-sleuth")
use("tpope/vim-speeddating")
use("tpope/vim-surround")
use({
  "tpope/vim-unimpaired",
  config = function()
    vim.g.nremap = { ["[a"] = "", ["]a"] = "" }
  end,
})

use({
  "tpope/vim-eunuch",
  config = function()
    vim.api.nvim_set_keymap("c", "w!!", "SudoWrite", { noremap = true })
  end,
})

use("tpope/vim-commentary")

use({
  "tpope/vim-fugitive",
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "<leader>gs",
      "<Cmd>Git<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>gc",
      "<Cmd>Git commit<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>gw",
      "<Cmd>Gwrite<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "",
      "<leader>gb",
      "<Cmd>GBrowse!<CR>",
      { noremap = true, silent = true }
    )
  end,
})
use("tommcdo/vim-fubitive")
use("tpope/vim-rhubarb")

use({ "tpope/vim-dadbod", cmd = "DB" })

if need_to_compile then
  packer.compile()
end

local script_name = debug.getinfo(1, "S").short_src
require("autocmd").add("BufWritePost", script_name, function()
  vim.cmd("luafile " .. script_name)
  packer.compile()
end, { augroup = "packer-config-reload" })
