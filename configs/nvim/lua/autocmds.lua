-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  group = augroup("yank_highlight", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Trim trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  callback = function()
    local save = vim.fn.winsaveview()
    pcall(vim.cmd, [[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- LSP attach: enable native completion + buffer-local LSP keymaps
autocmd("LspAttach", {
  group = augroup("lsp_attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Native LSP autocompletion (Neovim 0.11+)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "LSP: definition")
    bmap("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
    bmap("n", "gr", function() Snacks.picker.lsp_references() end, "LSP: references")
    bmap("n", "gI", vim.lsp.buf.implementation, "LSP: implementation")
    bmap("n", "gy", vim.lsp.buf.type_definition, "LSP: type definition")
    bmap("n", "K", vim.lsp.buf.hover, "LSP: hover")
    bmap("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: signature help")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
  end,
})

-- nvim-lint: trigger lint on common events
autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = augroup("nvim_lint", { clear = true }),
  callback = function() require("lint").try_lint() end,
})

-- Treesitter highlighting per-buffer (main branch requires manual start)
autocmd("FileType", {
  group = augroup("treesitter_start", { clear = true }),
  callback = function(args)
    local ft = args.match
    -- Try to start treesitter for this buffer; silently ignore if no parser.
    local ok, _ = pcall(vim.treesitter.start, args.buf)
    if ok then
      pcall(function() vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end)
    end
    _ = ft
  end,
})
