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
    local servers = {
      lua_ls = {
        executable = "lua-language-server",
        config = {
          handlers = {
            -- disable log messages, they aren't helpful
            ["window/logMessage"] = function() end,
            ["window/showMessage"] = function() end,
          },
          settings = {
            Lua = {
              addonManager = { enable = false },
              telemetry = { enable = false },
            },
          },
          on_init = function(client)
            -- if there's a `.luarc.json`, use it
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if vim.uv.fs_stat(vim.fs.joinpath(path, "/.luarc.json")) then
                return
              end
            end
            -- neovim specific config here
            client.config.settings.Lua =
              vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
                diagnostics = {
                  disable = { "newline-call" },
                  globals = { "vim" },
                },
                runtime = {
                  version = "LuaJIT",
                  path = { "lua/?.lua", "lua/?/init.lua" },
                },
                workspace = {
                  checkThirdParty = false,
                  library = { vim.env.VIMRUNTIME },
                  useGitIgnore = false,
                },
              })
          end,
        },
      },
      rust_analyzer = { executable = "rust-analyzer" },
      gopls = { executable = "gopls" },
    }
    for server, options in pairs(servers) do
      if vim.fn.executable(options.executable) == 1 then
        lspconfig[server].setup(options.config or {})
      end
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
        map("Q", vim.lsp.buf.hover)
        map("<leader>d", vim.diagnostic.open_float)
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
        "go",
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

pm.add({
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      signs = { add = { text = "+" }, change = { text = "~" } },
      signs_staged_enable = false,
      on_attach = function()
        local gs = require("gitsigns")
        vim.keymap.set("n", "]c", function()
          if vim.o.diff then
            vim.api.nvim_feedkeys("]c", "nt", true)
          else
            gs.nav_hunk("next")
          end
        end, { buffer = true })
        vim.keymap.set("n", "[c", function()
          if vim.o.diff then
            vim.api.nvim_feedkeys("[c", "nt", true)
          else
            gs.nav_hunk("prev")
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
        vim.keymap.set("n", "<leader>gw", gs.stage_buffer, { buffer = true })
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
      go = { "gofmt" },
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
        vim.api.nvim_feedkeys(vim.keycode("<C-y>"), "nx", false)
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
      paths = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets"),
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
        return vim.fs.joinpath(p, "lua", "?.lua")
      end, vim.o.runtimepath:split(","))
    end,
  },
  {
    "tpope/vim-scriptease",
    config = function()
      vim.keymap.set("n", "zS", function()
        return vim.bo.syntax == "" and vim.cmd.Inspect()
          or vim.fn["scriptease#synnames_map"](vim.v.count)
      end)
    end,
  },
  "tpope/vim-endwise",
  "tpope/vim-obsession",
  "tpope/vim-repeat",
  "tpope/vim-speeddating",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "tpope/vim-eunuch"
)

pm.add({
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", "<Cmd>Git<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gc", "<Cmd>Git commit<CR>", { silent = true })
    vim.keymap.set("", "<leader>gb", ":GBrowse!<CR>", { silent = true })
    vim.keymap.set("n", "<leader>gw", "<Cmd>Gwrite!<CR>", { silent = true })
  end,
}, "tommcdo/vim-fubitive", "tpope/vim-rhubarb")
