local config = function()
  require("nvim-treesitter.configs").setup({
    indent = {
      enable = true
    },
    autotag = {
      enable = true
    },
    ensure_installed = {
      "bash",
      "comment",
      "css",
      "diff",
      "dockerfile",
      "git_config",
      "gitignore",
      "go",
      "groovy",
      "hcl",
      "html",
      "java",
      "javascript",
      "json",
      "json5",
      "lua",
      "make",
      "markdown",
      "nix",
      "promql",
      "python",
      "regex",
      "scss",
      "sql",
      "terraform",
      "tmux",
      "toml",
      "typescript",
      "xml",
      "yaml",
      "vue",
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true,
    },
  })
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  config = config
}
