return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    ------------------------------------------------------------------
    -- Capabilities (completion, etc.)
    ------------------------------------------------------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    ------------------------------------------------------------------
    -- on_attach (buffer-local behavior)
    ------------------------------------------------------------------
    local function on_attach(client, bufnr)
      local map = function(keys, func, desc, modes)
        modes = modes or "n"
        vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
      end

      map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
      map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
      map("<leader>re", vim.lsp.buf.rename, "Rename")
      map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
      map("gD", vim.lsp.buf.declaration, "Goto Declaration")

      -- Document highlight
      if client.supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = bufnr,
          group = group,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = bufnr,
          group = group,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- Inlay hints
      if client.supports_method("textDocument/inlayHint") then
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
            { bufnr = bufnr }
          )
        end, "Toggle Inlay Hints")
      end
    end

    ------------------------------------------------------------------
    -- Python interpreter (Poetry-aware)
    ------------------------------------------------------------------
    local function get_poetry_python()
      local handle = io.popen("poetry env info -p 2>/dev/null")
      if not handle then
        return "python3"
      end
      local venv = handle:read("*a"):gsub("%s+", "")
      handle:close()
      if venv ~= "" then
        return venv .. "/bin/python"
      end
      return "python3"
    end

    ------------------------------------------------------------------
    -- LSP server definitions (NEW API)
    ------------------------------------------------------------------
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        python = {
          pythonPath = get_poetry_python(),
        },
      },
    })

    vim.lsp.config("ruff", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { disable = { "missing-fields" } },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
          completion = { callSnippet = "Replace" },
          format = { enable = false },
        },
      },
    })

    ------------------------------------------------------------------
    -- Enable servers
    ------------------------------------------------------------------
    vim.lsp.enable({
      "pyright",
      "ruff",
      "lua_ls",
    })
  end,
}

