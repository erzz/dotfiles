-- Plugin specification using native vim.pack (Neovim 0.12+). Omarchy may
-- already seed packages in the same native package directory, so reuse those
-- checkouts instead of trying to clone them again.
local function package_name(spec)
  if spec.name then return spec.name end
  return spec.src:match("/([^/]+)$"):gsub("%.git$", "")
end

local function add_plugins(specs)
  local missing = {}
  local install_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/"

  for _, spec in ipairs(specs) do
    local name = package_name(spec)
    if vim.fn.isdirectory(install_dir .. name) == 1 then
      vim.cmd.packadd(name)
    else
      missing[#missing + 1] = spec
    end
  end

  if #missing > 0 then
    vim.pack.add(missing, { confirm = false })
  end
end

add_plugins({
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
  { src = "https://github.com/folke/which-key.nvim" },

  -- Git
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Formatting / linting
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/mfussenegger/nvim-lint" },

  -- Tmux navigation
  { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
})

-- Omarchy's theme selector writes the active colorscheme to the user state
-- directory. Install its theme sources only on Omarchy; macOS keeps the
-- shared Tokyonight setup above.
if vim.fn.isdirectory("/usr/share/omarchy") == 1 then
  add_plugins({
    { src = "https://github.com/ribru17/bamboo.nvim" },
    { src = "https://github.com/bjarneo/aether.nvim", version = "v3" },
    { src = "https://github.com/bjarneo/ethereal.nvim" },
    { src = "https://github.com/bjarneo/hackerman.nvim" },
    { src = "https://github.com/bjarneo/vantablack.nvim" },
    { src = "https://github.com/bjarneo/white.nvim" },
    { src = "https://github.com/catppuccin/nvim" },
    { src = "https://github.com/neanias/everforest-nvim" },
    { src = "https://github.com/kepano/flexoki-neovim" },
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/rebelot/kanagawa.nvim" },
    { src = "https://github.com/tahayvr/matteblack.nvim" },
    { src = "https://github.com/loctvl842/monokai-pro.nvim" },
    { src = "https://github.com/EdenEast/nightfox.nvim" },
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/ficcdaf/ashen.nvim" },
    { src = "https://github.com/OldJobobo/miasma.nvim" },
    { src = "https://github.com/OldJobobo/retro-82.nvim" },
    { src = "https://github.com/omacom-io/lumon.nvim" },
  })
end
