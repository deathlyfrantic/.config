local pm = require("package-manager")

pm.init()

-- only used for running tests
pm.add({ "nvim-lua/plenary.nvim", opt = true })

pm.add({
  "neovim/nvim-lspconfig",
  config = function()
    -- put diagnostic config here just because it kinda makes sense
    vim.diagnostic.config({ signs = false })
    vim.keymap.set("n", "[a", function()
      vim.diagnostic.goto_prev({ float = false })
    end)
    vim.keymap.set("n", "]a", function()
      vim.diagnostic.goto_next({ float = false })
    end)
    vim.keymap.set("n", "Q", vim.diagnostic.open_float)
    local lspconfig = require("lspconfig")
    if vim.fn.executable("lua-language-server") == 1 then
      lspconfig.lua_ls.setup({})
    end
    if vim.fn.executable("rust-analyzer") == 1 then
      lspconfig.rust_analyzer.setup({})
    end
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-config", {}),
      callback = function(event)
        vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
        -- let ale format buffers, lsp formatting is hit or miss
        vim.bo[event.buf].formatexpr = ""
        ---@param key string
        ---@param fn function
        ---@param mode? string | string[]
        local function map(key, fn, mode)
          vim.keymap.set(mode or "n", key, fn, { buffer = event.buf })
        end
        -- if keywordprg is ":help" (or some other :command), don't map K
        if not vim.bo[event.buf].keywordprg:starts_with(":") then
          map("K", vim.lsp.buf.signature_help)
        end
        -- hover or show diagnostics based on whether line has diagnostics
        map("Q", function()
          local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
          local diagnostics = vim.diagnostic.get(0, { lnum = lnum })
          if #diagnostics == 0 then
            vim.lsp.buf.hover()
          else
            vim.diagnostic.open_float()
          end
        end)
        map("gd", vim.lsp.buf.definition)
        map("<C-]>", vim.lsp.buf.type_definition)
        map("<leader>ca", vim.lsp.buf.code_action, { "n", "v" })
        map("<leader>rn", vim.lsp.buf.rename)
        map("gr", vim.lsp.buf.references)
      end,
    })
  end,
})

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
      status_formatter = require("statusline").gitsigns_status,
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
      group = vim.api.nvim_create_augroup("gitsigns-config", {}),
    })
  end,
})

pm.add({
  "dense-analysis/ale",
  config = function()
    local group = vim.api.nvim_create_augroup("ale-config", {})
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
    vim.g.ale_lua_stylua_options = "--search-parent-directories"
    vim.g.ale_sh_shellcheck_dialect = "bash"
  end,
})

pm.add({
  "justinmk/vim-dirvish",
  config = function()
    local function toggle()
      local dirvish_bufs = vim.tbl_filter(function(id)
        return vim.api.nvim_buf_is_loaded(id)
          and vim.bo[id].filetype == "dirvish"
      end, vim.api.nvim_list_bufs())
      if #dirvish_bufs == 0 then
        vim.cmd.vsplit({ mods = { split = "topleft" }, range = { 35 } })
        vim.cmd.Dirvish()
      else
        vim.cmd.bdelete({ args = dirvish_bufs, bang = true })
      end
    end
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dirvish",
      callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.statusline = "%F"
        vim.keymap.set("n", "<CR>", function()
          local line = vim.api.nvim_get_current_line()
          if line:ends_with("/") then
            vim.fn["dirvish#open"]("edit", 0)
          else
            toggle()
            vim.cmd.edit(line)
          end
        end, { buffer = true, silent = true })
        vim.cmd.global({
          args = { [[@\v/\.[^\/]+/?$@d]] },
          mods = { keeppatterns = true, silent = true, emsg_silent = true },
        })
        for _, pattern in ipairs(vim.o.wildignore:split(",")) do
          vim.cmd.global({
            args = { ([[@\v/%s/?$@d]]):format(pattern) },
            mods = { keeppatterns = true, silent = true, emsg_silent = true },
          })
        end
        vim.keymap.set("n", "q", toggle, { buffer = true, silent = true })
        vim.keymap.set(
          "n",
          "-",
          "<Plug>(dirvish_up)",
          { buffer = true, remap = true }
        )
      end,
      group = vim.api.nvim_create_augroup("dirvish-config", {}),
    })
    vim.keymap.set("n", "-", toggle, { silent = true, remap = true })
    vim.g.dirvish_mode = ":sort ,^.*[/],"
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
      require("completion").wrap("tmuxcomplete#complete")
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
    vim.keymap.set({ "i", "s" }, "<C-]>", function()
      -- need to close the completion menu if it is open, otherwise luasnip gets
      -- a little wonky
      if vim.fn.pumvisible() == 1 then
        vim.api.nvim_feedkeys(vim.keycode("<C-y>"), "mx", false)
      end
      ls.expand_or_jump()
    end)
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
  "tpope/vim-eunuch"
)

pm.add({
  "tpope/vim-fugitive",
  config = function()
    -- this is a modified version of vim-fugitive-blame-ext by Tom McDonald
    -- see: https://github.com/tommcdo/vim-fugitive-blame-ext
    local subj_cmd = "git --git-dir=%s show -s --pretty=format:%%s %s"
    local full_cmd = "git --git-dir=%s show -s --format=medium --color=never %s"

    local function log_message()
      local commit = vim.api.nvim_get_current_line():match("^%^?([0-9A-Fa-f]+)")
      if commit:match("^0+$") then
        return { subj = "(Not Committed Yet)" }
      end
      if not vim.b.blame_messages or not vim.b.blame_messages[commit] then
        local subj = io.popen(subj_cmd:format(vim.b.git_dir, commit))
          :read("*all")
        local full = io.popen(full_cmd:format(vim.b.git_dir, commit))
          :read("*all")
        -- can't insert a value into a vim.b table; have to reassign the whole
        -- thing
        vim.b.blame_messages = vim.tbl_extend(
          "force",
          vim.b.blame_messages or {},
          { [commit] = { subj = subj, full = full } }
        )
      end
      return vim.b.blame_messages[commit]
    end

    local group = vim.api.nvim_create_augroup("fugitive-config-blame", {})
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
      pattern = "*.fugitiveblame",
      callback = function()
        vim.defer_fn(function()
          vim.api.nvim_echo(
            { { log_message().subj:sub(1, vim.o.columns - 1) } },
            false,
            {}
          )
        end, 100)
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitiveblame",
      callback = function()
        vim.keymap.set("n", "Q", function()
          local blame = log_message()
          if not blame.full then
            return
          end
          local popup_window = require("utils").popup(blame.full)
          vim.api.nvim_create_autocmd(
            { "CursorMoved", "BufLeave", "BufWinLeave" },
            {
              buffer = 0,
              callback = function()
                if vim.api.nvim_win_is_valid(popup_window) then
                  vim.api.nvim_win_close(popup_window, true)
                end
              end,
              once = true,
              group = group,
            }
          )
        end, { buffer = true })
      end,
      group = group,
    })
    vim.keymap.set("n", "<leader>gs", "<Cmd>Git<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gc", "<Cmd>Git commit<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gw", "<Cmd>Gwrite<CR>", { silent = true })
    vim.keymap.set("", "<leader>gb", ":GBrowse!<CR>", { silent = true })
  end,
}, "tommcdo/vim-fubitive", "tpope/vim-rhubarb")
