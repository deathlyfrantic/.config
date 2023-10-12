local pm = require("z.package-manager")

pm.init()

pm.add("nvim-lua/plenary.nvim")

pm.add({
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "diff",
        "gitcommit",
        "javascript",
        "json",
        "markdown",
        "python",
        "rust",
        "toml",
        "typescript",
        "yaml",
      },
      highlight = { enable = true },
    })
  end,
})

pm.add(
  { "rust-lang/rust.vim", ft = "rust" },
  { "pangloss/vim-javascript", ft = "javascript" }
)

pm.add(
  "Julian/vim-textobj-variable-segment",
  "kana/vim-textobj-user",
  "michaeljsmith/vim-indent-object",
  "glts/vim-textobj-comment",
  "deathlyfrantic/vim-textobj-blanklines"
)

pm.add({
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      signs = { add = { text = "+" }, change = { text = "~" } },
      on_attach = function()
        local gs = require("gitsigns")
        vim.keymap.set("n", "]c", function()
          if vim.o.diff then
            vim.api.nvim_feedkeys("]c", "nt", true)
          else
            gs.next_hunk()
          end
        end, { buffer = true })
        vim.keymap.set("n", "[c", function()
          if vim.o.diff then
            vim.api.nvim_feedkeys("[c", "nt", true)
          else
            gs.prev_hunk()
          end
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
      group = vim.api.nvim_create_augroup("z-gitsigns-config", {}),
    })
  end,
})

pm.add({
  "dense-analysis/ale",
  config = function()
    vim.keymap.set("n", "[a", "<Cmd>ALEPreviousWrap<CR>", { silent = true })
    vim.keymap.set("n", "]a", "<Cmd>ALENextWrap<CR>", { silent = true })
    vim.keymap.set("n", "Q", "<Cmd>ALEDetail<CR>", { silent = true })
    local group = vim.api.nvim_create_augroup("z-ale-config", {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ale-preview",
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.colorcolumn = "0"
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ale-preview.message",
      callback = function()
        vim.opt_local.colorcolumn = "0"
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
    vim.g.ale_use_neovim_diagnostics_api = 1
    vim.g.ale_hover_to_floating_preview = 1
    vim.g.ale_detail_to_floating_preview = 1
    vim.g.ale_floating_window_border = { " ", " ", " ", " ", " ", " " }
    vim.g.ale_fixers = {
      ["*"] = { "remove_trailing_lines", "trim_whitespace" },
      rust = { "rustfmt" },
      javascript = { "deno", "prettier" },
      javascriptreact = { "deno", "prettier" },
      typescript = { "deno", "prettier" },
      typescriptreact = { "deno", "prettier" },
      -- order of json fixers is important: always fix with jq, but if the
      -- repo has prettier installed, fix with it second; this way json files in
      -- repos that have prettier get fixed by prettier, but other json files at
      -- least get fixed by jq.
      json = { "jq", "prettier" },
      lua = { "stylua" },
    }
    vim.g.ale_fix_on_save = 1
    vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy")
    vim.g.ale_linters = { zsh = { "shell", "shellcheck" } }
    vim.g.ale_c_clang_options =
      "-fsyntax-only -std=c11 -Wall -Wno-unused-parameter -Werror"
    vim.g.ale_lua_stylua_options = "--config-path "
      .. vim.fs.normalize("$XDG_CONFIG_HOME/stylua.toml")
    vim.g.ale_sh_shellcheck_dialect = "bash"
  end,
})

pm.add({
  "junegunn/goyo.vim",
  cmd = "Goyo",
  config = function()
    vim.g.goyo_height = "96%"
    vim.g.goyo_width = 82
    local autocmd_handle
    local group = vim.api.nvim_create_augroup("z-goyo-config", {})
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

pm.add({
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
      group = vim.api.nvim_create_augroup("z-dirvish-config", {}),
    })
  end,
})

pm.add({
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

pm.add({
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

pm.add({
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

pm.add({
  "wellle/tmux-complete.vim",
  config = function()
    vim.g["tmuxcomplete#trigger"] = ""
    vim.keymap.set("i", "<C-x><C-t>", function()
      require("z.completion").wrap("tmuxcomplete#complete")
    end)
  end,
})

pm.add({
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")
    ls.config.setup({
      history = false,
      update_events = "TextChanged,TextChangedI",
    })
    vim.keymap.set({ "i", "s" }, "<C-]>", ls.expand_or_jump)
    vim.keymap.set({ "i", "s" }, "<C-f>", function()
      ls.jump(1)
    end)
    vim.keymap.set({ "i", "s" }, "<C-b>", function()
      ls.jump(-1)
    end)
    vim.keymap.set({ "i", "s" }, "<C-e>", function()
      if ls.choice_active() then
        return "<Plug>luasnip-next-choice"
      end
      return "<C-e>"
    end, { expr = true })
    vim.keymap.set({ "i", "s" }, "<C-y>", function()
      if ls.choice_active() then
        return "<Plug>luasnip-prev-choice"
      end
      return "<C-y>"
    end, { expr = true })
    require("luasnip.loaders.from_lua").load({
      paths = vim.fn.stdpath("config") .. "/snippets",
    })
    ls.filetype_extend("typescript", { "javascript" })
  end,
})

pm.add("tommcdo/vim-exchange", {
  "tommcdo/vim-lion",
  config = function()
    vim.g.lion_squeeze_spaces = 1
  end,
})

pm.add(
  "tpope/vim-abolish",
  {
    "tpope/vim-apathy",
    config = function()
      vim.g.lua_path = vim.tbl_map(function(p)
        return p .. "/lua/?.lua"
      end, vim.o.runtimepath:split(","))
    end,
  },
  { "tpope/vim-dadbod", cmd = "DB" },
  "tpope/vim-endwise",
  "tpope/vim-obsession",
  "tpope/vim-repeat",
  "tpope/vim-scriptease",
  "tpope/vim-sleuth",
  "tpope/vim-speeddating",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "tpope/vim-eunuch",
  "tpope/vim-commentary"
)

pm.add({
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", "<Cmd>Git<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gc", "<Cmd>Git commit<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gw", "<Cmd>Gwrite<CR>", { silent = true })
    vim.keymap.set("", "<leader>gb", ":GBrowse!<CR>", { silent = true })
  end,
}, "tommcdo/vim-fubitive", "tpope/vim-rhubarb")
