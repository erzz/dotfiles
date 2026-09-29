-- Follow Omarchy's generated theme selection while keeping the shared native
-- vim.pack configuration authoritative.
local M = {}

local theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
local transparency_file = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"
local applied_colorscheme

local function current_colorscheme()
  if vim.fn.filereadable(theme_file) ~= 1 then return "tokyonight-night" end
  local source = table.concat(vim.fn.readfile(theme_file), "\n")
  return source:match("colorscheme%s*=%s*[\"']([^\"']+)[\"']") or "tokyonight-night"
end

local function apply()
  local colorscheme = current_colorscheme()
  if colorscheme == applied_colorscheme then return end
  if pcall(vim.cmd.colorscheme, colorscheme) then
    applied_colorscheme = colorscheme
    if vim.fn.filereadable(transparency_file) == 1 then
      pcall(vim.cmd.source, transparency_file)
    end
  end
end

function M.setup()
  vim.schedule(apply)

  local timer = vim.uv.new_timer()
  timer:start(2000, 2000, vim.schedule_wrap(apply))
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function() timer:stop(); timer:close() end,
  })
end

return M
