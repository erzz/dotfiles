-- conform.nvim: format-on-save with sensible per-language pickers.
-- Binaries installed via the native mise/Homebrew declarations.

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofumpt" },
    python = { "black" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    terraform = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
    java = { "google-java-format" },
  },
  format_on_save = function(bufnr)
    -- Allow disabling per buffer via b:disable_autoformat
    if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then return end
    return { timeout_ms = 1500, lsp_format = "fallback" }
  end,
})

-- Toggle commands
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
end, { desc = "Disable autoformat-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })

-- Run gopls organize-imports synchronously before save (avoids race with conform)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params(0, "utf-8")
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        end
      end
    end
  end,
})
