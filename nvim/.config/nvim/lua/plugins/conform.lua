return {
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 2500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      go = { 'goimports', 'gofmt' },
      javascript = { { 'prettierd', 'prettier' } },
      lua = { 'stylua' },
      markdown = { { 'prettierd', 'prettier', 'markdown' } },
      mdx = { { 'prettierd', 'prettier', 'mdx', 'markdown' } },
      python = { 'isort', 'black' },
      yaml = { 'prettier', 'prettierd' },
    },
    ft_parsers = {
      ['markdown.mdx'] = 'mdx',
    },
  },
}
