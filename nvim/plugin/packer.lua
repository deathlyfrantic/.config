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

use({ "nvim-lua/plenary.nvim" })

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
  config = function()
    require("gitsigns").setup({
      signs = { add = { text = "+" }, change = { text = "~" } },
      on_attach = function()
        local gs = require("gitsigns")
        vim.keymap.set("n", "]c", function()
          if vim.o.diff then
            vim.api.nvim_input("]c")
          end
          gs.next_hunk()
        end, { buffer = true })
        vim.keymap.set("n", "[c", function()
          if vim.o.diff then
            vim.api.nvim_input("[c")
          end
          gs.prev_hunk()
        end, { buffer = true })
        vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { buffer = true })
        vim.keymap.set("v", "<leader>hs", function()
          gs.stage_hunk({ vim.api.nvim_win_get_cursor(0)[1], vim.fn.line("v") })
        end, { buffer = true })
        vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { buffer = true })
        vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = true })
        vim.keymap.set("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { buffer = true })
        vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { buffer = true })
        vim.keymap.set({ "o", "x" }, "ig", gs.select_hunk, { buffer = true })
      end,
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
    vim.api.nvim_create_autocmd("User", {
      pattern = "ALEFixPost",
      callback = function()
        require("gitsigns").refresh()
      end,
      group = vim.api.nvim_create_augroup("packer-gitsigns-config", {}),
    })
  end,
})

use({
  "dense-analysis/ale",
  config = function()
    vim.keymap.set("n", "[a", "<Cmd>ALEPreviousWrap<CR>", { silent = true })
    vim.keymap.set("n", "]a", "<Cmd>ALENextWrap<CR>", { silent = true })
    vim.keymap.set("n", "Q", "<Cmd>ALEDetail<CR>", { silent = true })
    local group = vim.api.nvim_create_augroup("packer-ale-config", {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ale-preview",
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.cmd.setlocal("colorcolumn=0")
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ale-preview.message",
      callback = function()
        vim.cmd.setlocal("colorcolumn=0")
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "rust", "typescript" },
      callback = function()
        vim.bo.omnifunc = "ale#completion#OmniFunc"
        vim.keymap.set(
          "n",
          "gd",
          "<Plug>(ale_go_to_definition)",
          { buffer = true, remap = true }
        )
        vim.keymap.set(
          "n",
          "K",
          "<Plug>(ale_hover)",
          { buffer = true, remap = true }
        )
        vim.keymap.set(
          "n",
          "<C-w>i",
          "<Plug>(ale_go_to_definition_in_split)",
          { buffer = true, remap = true }
        )
      end,
      group = group,
    })
    vim.g.ale_hover_to_floating_preview = 1
    vim.g.ale_floating_window_border = { " ", " ", " ", " ", " ", " " }
    vim.g.ale_fixers = {
      ["*"] = { "remove_trailing_lines", "trim_whitespace" },
      rust = { "rustfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      -- order of json fixers is important: always fix with jq, but if the
      -- repo has prettier installed, fix with it second; this way json files in
      -- repos that have prettier get fixed by prettier, but other json files at
      -- least get fixed by jq.
      json = { "jq", "prettier" },
      lua = { "stylua" },
    }
    vim.g.ale_fix_on_save = 1
    vim.g.ale_fix_on_save_ignore = { mail = { "trim_whitespace" } }
    vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy")
    if vim.fn.executable("rust-analyzer") then
      vim.g.ale_linters = { rust = { "analyzer", "cargo" } }
    end
    vim.g.ale_c_clang_options =
      "-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror"
    vim.g.ale_lua_stylua_options = "--config-path "
      .. vim.fs.normalize("$XDG_CONFIG_HOME/stylua.toml")
  end,
})

use({
  "junegunn/goyo.vim",
  cmd = "Goyo",
  config = function()
    vim.g.goyo_height = "96%"
    vim.g.goyo_width = 82
    local autocmd_handle
    local group = vim.api.nvim_create_augroup("packer-goyo-config", {})
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoEnter",
      callback = function()
        vim.o.showmode = false
        vim.o.showcmd = false
        vim.o.showtabline = 0
        autocmd_handle = vim.api.nvim_create_autocmd(
          { "CursorHold", "CursorHoldI" },
          {
            pattern = "*",
            callback = function()
              vim.api.nvim_echo({}, false, {})
            end,
            group = vim.api.nvim_create_augroup("goyo-cursorhold-clear", {}),
          }
        )
      end,
      nested = true,
      group = group,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoLeave",
      callback = function()
        vim.o.showmode = true
        vim.o.showcmd = true
        vim.fn["buftabline#update"](0)
        vim.api.nvim_del_autocmd(autocmd_handle)
      end,
      nested = true,
      group = group,
    })
  end,
})

use({
  "justinmk/vim-dirvish",
  config = function()
    vim.g.dirvish_mode = ":sort ,^.*[/],"
    vim.keymap.set("n", "-", "<Plug>(dirvish-toggle)", { remap = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dirvish",
      callback = function()
        vim.keymap.set(
          "n",
          "-",
          "<Plug>(dirvish_up)",
          { buffer = true, remap = true }
        )
      end,
      group = vim.api.nvim_create_augroup("packer-dirvish-config", {}),
    })
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
    vim.keymap.set("n", "<C-q>", "<Cmd>UndotreeToggle<CR>", { silent = true })
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
    vim.keymap.set("n", "<C-t>", "<Cmd>TagbarToggle<CR>", { silent = true })
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
      vim.keymap.set(
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
    vim.keymap.set("i", "<C-x><C-t>", function()
      _G.completion.wrap("tmuxcomplete#complete")
    end)
  end,
})

use({
  "norcalli/snippets.nvim",
  config = function()
    local snippets = require("snippets")
    vim.keymap.set("i", "<C-]>", snippets.expand_at_cursor)
    vim.keymap.set("i", "<C-f>", function()
      snippets.advance_snippet(1)
    end)
    vim.keymap.set("i", "<C-b>", function()
      snippets.advance_snippet(-1)
    end)
    snippets.snippets = require("my-snippets")
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

use({
  "tpope/vim-apathy",
  config = function()
    vim.g.lua_path = vim.tbl_map(function(p)
      return p .. "/lua/?.lua"
    end, vim.split(vim.o.runtimepath, ","))
  end,
})

use("tpope/vim-abolish")
use("tpope/vim-endwise")
use("tpope/vim-obsession")
use("tpope/vim-repeat")
use("tpope/vim-scriptease")
use("tpope/vim-sleuth")
use("tpope/vim-speeddating")
use("tpope/vim-surround")
use("tpope/vim-unimpaired")
use("tpope/vim-eunuch")
use("tpope/vim-commentary")

use({
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", "<Cmd>Git<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gc", "<Cmd>Git commit<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gw", "<Cmd>Gwrite<CR>", { silent = true })
    vim.keymap.set("", "<leader>gb", ":GBrowse!<CR>", { silent = true })
  end,
})
use("tommcdo/vim-fubitive")
use("tpope/vim-rhubarb")

use({ "tpope/vim-dadbod", cmd = "DB" })

if need_to_compile then
  packer.compile()
end

local script_name = debug.getinfo(1, "S").short_src
if not _G.have_set_packer_compile_autocmd then
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = script_name,
    callback = function()
      vim.cmd.luafile(script_name)
      packer.compile()
    end,
    group = vim.api.nvim_create_augroup("packer-config-reload", {}),
  })
  _G.have_set_packer_compile_autocmd = true
end
