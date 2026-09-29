-- nvim-treesitter "main" branch: install parsers explicitly, start per buffer.
-- The FileType autocmd in autocmds.lua calls vim.treesitter.start().

local ts = require("nvim-treesitter")
ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local parsers = {
  "bash",
  "diff",
  "dockerfile",
  "git_config",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "hcl",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- Install missing parsers asynchronously (no-op if already installed).
pcall(function()
  ts.install(parsers)
end)

-- Textobjects (main branch as well; uses queries shipped with the plugin)
pcall(function()
  require("nvim-treesitter-textobjects").setup({
    select = {
      lookahead = true,
    },
  })
end)
