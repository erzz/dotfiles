-- LSP server configuration using vim.lsp.config + vim.lsp.enable (Neovim 0.11+).
-- Binaries installed via brew (see brew/Brewfile).

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Per-server config
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = { globals = { "vim", "Snacks" } },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = { unusedparams = true, shadow = true },
      staticcheck = true,
    },
  },
})

vim.lsp.config("ts_ls", {})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "openFilesOnly",
        autoImportCompletions = true,
      },
    },
  },
})

vim.lsp.config("terraformls", {})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
        ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
      },
    },
  },
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      validate = { enable = true },
    },
  },
})

vim.lsp.config("marksman", {})
vim.lsp.config("dockerls", {})
vim.lsp.config("docker_compose_language_service", {})
vim.lsp.config("bashls", {})
vim.lsp.config("jdtls", {
  -- Minimal config. For full Java workspace features (debug, test runner,
  -- per-project workspace), consider mfussenegger/nvim-jdtls.
})

-- Enable all configured servers
vim.lsp.enable({
  "lua_ls",
  "gopls",
  "ts_ls",
  "pyright",
  "terraformls",
  "yamlls",
  "jsonls",
  "marksman",
  "dockerls",
  "docker_compose_language_service",
  "bashls",
  "jdtls",
})
