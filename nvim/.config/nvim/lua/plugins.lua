-- Plugin specification using native vim.pack (Neovim 0.12+)
-- vim.pack.add is synchronous: plugins are available for `require` immediately after.
vim.pack.add({
  -- Colorscheme
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- Treesitter (main branch — required for 0.12)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

  -- Editing
  { src = "https://github.com/echasnovski/mini.files" },
  { src = "https://github.com/echasnovski/mini.icons" },

  -- LSP defaults (cmd / filetypes / root_markers for ~300 servers; no framework)
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- UI
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/folke/snacks.nvim" },

  -- Git
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Formatting / linting
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/mfussenegger/nvim-lint" },

  -- Tmux navigation
  { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
})
