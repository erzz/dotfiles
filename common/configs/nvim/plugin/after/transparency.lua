-- Preserve Omarchy's transparent editor surface on supported themes.
if vim.fn.isdirectory("/usr/share/omarchy") ~= 1 then return end

local function make_transparent(name)
  local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok then
    highlight.bg = nil
    vim.api.nvim_set_hl(0, name, highlight)
  end
end

for _, name in ipairs({
  "Normal", "NormalFloat", "FloatBorder", "Pmenu", "Terminal", "EndOfBuffer",
  "FoldColumn", "Folded", "SignColumn", "LineNr", "CursorLineNr", "NormalNC",
  "WhichKeyFloat", "TelescopeBorder", "TelescopeNormal", "TelescopePromptBorder",
  "TelescopePromptTitle", "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeVertSplit",
  "NeoTreeWinSeparator", "NeoTreeEndOfBuffer", "NvimTreeNormal", "NvimTreeVertSplit",
  "NvimTreeEndOfBuffer", "NotifyINFOBody", "NotifyERRORBody", "NotifyWARNBody",
  "NotifyTRACEBody", "NotifyDEBUGBody", "NotifyINFOTitle", "NotifyERRORTitle",
  "NotifyWARNTitle", "NotifyTRACETitle", "NotifyDEBUGTitle", "NotifyINFOBorder",
  "NotifyERRORBorder", "NotifyWARNBorder", "NotifyTRACEBorder", "NotifyDEBUGBorder",
}) do
  make_transparent(name)
end
