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

      map("gd", vim.lsp.buf.definition, "Go to Definition")
      map("gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("gr", vim.lsp.buf.references, "Go to References")
      map("K",  vim.lsp.buf.hover, "Hover Docs")
      map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
      map("<leader>re", vim.lsp.buf.rename, "Rename")
      map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })

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


      if client.name == "zls" then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              async = false,
              filter = function(c)
                return c.name == "zls"
              end,
            })
          end,
        })
      end
    end

    ------------------------------------------------------------------
    -- LSP server definitions (NEW API)
    ------------------------------------------------------------------
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
          },
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

    vim.lsp.config("zls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        zls = {
          enable_inlay_hints = true,
          enable_snippets = true,
          warn_style = true,
        },
      },
    })

    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = true,
          check = { command = "clippy" },
          procMacro = { enable = true },
          inlayHints = {
            bindingModeHints = { enable = true },
            chainingHints = { enable = true },
            closureReturnTypeHints = { enable = "always" },
            parameterHints = { enable = true },
            typeHints = { enable = true },
          },
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
      "zls",
      "rust_analyzer",
    })

  end,
}

