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
      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end
      local map = function(keys, func, desc, modes)
        modes = modes or "n"
        vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
      end

      map("gd", vim.lsp.buf.definition, "Go to Definition")
      map("gD", vim.lsp.buf.declaration, "Go to Declaration")
      map("gi", vim.lsp.buf.implementation, "Go to Implementation")
      map("gr", vim.lsp.buf.references, "Go to References")
      map("K", vim.lsp.buf.hover, "Hover Docs")
      map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
      map("<leader>re", vim.lsp.buf.rename, "Rename")
      map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })

      map("<leader>ci", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" }, diagnostics = {} },
          apply = true,
        })
      end, "Organize Imports")
      map("<leader>cs", vim.lsp.buf.signature_help, "Function Signature", { "n", "i" })

      -- Document highlight
      if client:supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })
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
      if client:supports_method("textDocument/inlayHint") then
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
            { bufnr = bufnr }
          )
        end, "Toggle Inlay Hints")
      end
    end

    -- LspAttach leaves upstream server-specific on_attach hooks intact.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("ide-lsp-attach", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
          on_attach(client, event.buf)
        end
      end,
    })
    vim.lsp.config("*", { capabilities = capabilities })

    ------------------------------------------------------------------
    -- LSP server definitions (NEW API)
    ------------------------------------------------------------------
    vim.lsp.config("pyright", {
      before_init = function(_, config)
        config.settings.python.pythonPath = require("core.python").resolve(config.root_dir)
      end,
      settings = {
        pyright = { disableOrganizeImports = true }, -- Ruff owns import sorting.
        python = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
          },
        },
      },
    })

    vim.lsp.config("eslint", {
      settings = { workingDirectory = { mode = "auto" }, format = false },
    })

    vim.lsp.config("vtsls", {
      handlers = { ["textDocument/publishDiagnostics"] = require("core.imports").on_diagnostics },
      settings = {
        vtsls = { autoUseWorkspaceTsdk = true },
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = { completeFunctionCalls = true },
          inlayHints = {
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
          },
        },
        javascript = { updateImportsOnFileMove = { enabled = "always" } },
      },
    })

    vim.lsp.config("lua_ls", {
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
      settings = {
        zls = {
          enable_inlay_hints = true,
          enable_snippets = true,
          warn_style = true,
        },
      },
    })

    ------------------------------------------------------------------
    -- Enable servers
    ------------------------------------------------------------------
    vim.lsp.enable({
      "pyright",
      "ruff",
      "vtsls",
      "eslint",
      "lua_ls",
    })
    if vim.fn.executable("zls") == 1 then
      vim.lsp.enable("zls")
    end
  end,
}
