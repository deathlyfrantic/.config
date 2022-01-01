local packer_path = vim.fn.stdpath("config") .. "/pack/packer/start/packer.nvim"

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

use({
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "javascript", "rust" },
      highlight = { enable = false },
    })
  end,
})

use({ "rust-lang/rust.vim", ft = "rust" })
use({ "pangloss/vim-javascript", ft = "javascript" })

use("Julian/vim-textobj-variable-segment")
use("kana/vim-textobj-user")
use("michaeljsmith/vim-indent-object")
use("glts/vim-textobj-comment")
use("deathlyfrantic/vim-textobj-blanklines")

use({
  "lewis6991/gitsigns.nvim",
  requires = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitsigns").setup({
      signs = { add = { text = "+" }, change = { text = "~" } },
      keymaps = {
        ["n ]c"] = {
          expr = true,
          [[&diff ? "]c" : '<Cmd>lua require("gitsigns.actions").next_hunk()<CR>']],
        },
        ["n [c"] = {
          expr = true,
          [[&diff ? "[c" : '<Cmd>lua require("gitsigns.actions").prev_hunk()<CR>']],
        },
        ["n <leader>hs"] = '<Cmd>lua require("gitsigns").stage_hunk()<CR>',
        ["v <leader>hs"] = '<Cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
        ["n <leader>hu"] = '<Cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
        ["n <leader>hr"] = '<Cmd>lua require("gitsigns").reset_hunk()<CR>',
        ["n <leader>hb"] = '<Cmd>lua require("gitsigns").blame_line(true)<CR>',
        ["n <leader>hp"] = '<Cmd>lua require("gitsigns").preview_hunk()<CR>',
        ["o ig"] = ':<C-u>lua require("gitsigns.actions").select_hunk()<CR>',
        ["x ig"] = ':<C-u>lua require("gitsigns.actions").select_hunk()<CR>',
      },
      preview_config = { border = "solid" },
      status_formatter = function(status)
        local ret = status.head
        if not ret or ret == "" then
          return ""
        end
        local text = {}
        for k, v in pairs({
          ["+"] = status.added,
          ["~"] = status.changed,
          ["-"] = status.removed,
        }) do
          if (v or 0) > 0 then
            table.insert(text, k .. v)
          end
        end
        if #text > 0 then
          ret = ret .. "/" .. table.concat(text)
        end
        return "[" .. ret .. "]"
      end,
      attach_to_untracked = false,
    })
    -- when ALE formats a buffer by replacing it with an entirely new copy that
    -- is mostly the same, gitsigns gets confused and thinks the entire buffer
    -- has been changed. this autocmd force-refreshes gitsigns immediately after
    -- a buffer is fixed to correct that problem.
    require("autocmd").add("User", "ALEFixPost", function()
      require("gitsigns").refresh()
    end, {
      augroup = "packer-gitsigns-config",
    })
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
        vim.cmd("setlocal colorcolumn=0")
      end)
      add("FileType", "ale-preview.message", function()
        vim.cmd("setlocal colorcolumn=0")
      end)
      add("FileType", "rust,typescript", function()
        vim.bo.omnifunc = "ale#completion#OmniFunc"
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "gd",
          "<Plug>(ale_go_to_definition)",
          {}
        )
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
    vim.g.ale_linters_ignore = { json = { "eslint" } }
    if vim.fn.executable("rust-analyzer") then
      vim.g.ale_linters = { rust = { "analyzer", "cargo" } }
    end
    vim.g.ale_c_clang_options =
      "-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror"
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
        autocmd_handle = require("autocmd").add(
          "CursorHold,CursorHoldI",
          "*",
          function()
            vim.api.nvim_echo({}, false, {})
          end,
          { augroup = "goyo-cursorhold-clear", unique = true }
        )
      end, {
        nested = true,
      })
      add("User", "GoyoLeave", function()
        vim.o.showmode = true
        vim.o.showcmd = true
        vim.fn["buftabline#update"](0)
        require("autocmd").del(autocmd_handle)
      end, {
        nested = true,
      })
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
  end,
  setup = function()
    vim.api.nvim_set_keymap(
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
  end,
  setup = function()
    vim.api.nvim_set_keymap(
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
      "<Cmd>call v:lua.completion.wrap('tmuxcomplete#complete')<CR>",
      { noremap = true }
    )
  end,
})

use({
  "norcalli/snippets.nvim",
  config = function()
    local snippets = require("snippets")
    snippets.set_ux(require("snippets.inserters.text_markers"))
    vim.api.nvim_set_keymap(
      "i",
      "<C-]>",
      [[<Cmd>lua require("snippets").expand_at_cursor()<CR>]],
      { noremap = true }
    )
    vim.api.nvim_set_keymap(
      "i",
      "<C-f>",
      [[<Cmd>lua require("snippets").advance_snippet(1)<CR>]],
      { noremap = true }
    )
    vim.api.nvim_set_keymap(
      "i",
      "<C-b>",
      [[<Cmd>lua require("snippets").advance_snippet(-1)<CR>]],
      { noremap = true }
    )
    snippets.snippets = require("my_snippets")
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
      ":GBrowse!<CR>",
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
end, {
  augroup = "packer-config-reload",
})
