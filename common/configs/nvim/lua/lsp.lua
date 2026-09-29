-- LSP server configuration using vim.lsp.config + vim.lsp.enable (Neovim 0.11+).
-- Binaries installed via the native mise/Homebrew declarations.

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

-- Enable only servers whose command is available. This keeps Neovim usable
-- while a fresh machine is still converging its editor tool inventory.
local mise_root = vim.fn.expand("$HOME/dotfiles")
local server_commands = {
  lua_ls = { command = "lua-language-server" },
  gopls = { command = "gopls" },
  ts_ls = { command = "typescript-language-server" },
  pyright = { command = "pyright-langserver" },
  terraformls = { command = "terraform-ls" },
  yamlls = { command = "yaml-language-server" },
  jsonls = { command = "vscode-json-language-server" },
  marksman = { command = "marksman" },
  dockerls = { command = "docker-langserver", via_mise = true },
  docker_compose_language_service = { command = "docker-compose-langserver", via_mise = true },
  bashls = { command = "bash-language-server" },
  jdtls = { command = "jdtls" },
}

local enabled_servers = {}
for server, spec in pairs(server_commands) do
  local available = vim.fn.executable(spec.command) == 1
  if not available and spec.via_mise and vim.fn.executable("mise") == 1 then
    vim.lsp.config(server, {
      cmd = { "mise", "--cd", mise_root, "x", "--", spec.command },
    })
    vim.fn.system({ "mise", "--cd", mise_root, "which", spec.command })
    available = vim.v.shell_error == 0
  end
  if available then
    enabled_servers[#enabled_servers + 1] = server
  end
end
vim.lsp.enable(enabled_servers)
