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
    -- Python interpreter (Poetry, UV, and venv-aware)
    ------------------------------------------------------------------
    local function get_python_path()
      -- Check for UV environment first (VIRTUAL_ENV is set by uv venv activate)
      local uv_venv = os.getenv("VIRTUAL_ENV")
      if uv_venv and uv_venv ~= "" then
        return uv_venv .. "/bin/python"
      end
      
      -- Check for Poetry environment
      local handle = io.popen("poetry env info -p 2>/dev/null")
      if handle then
        local venv = handle:read("*a"):gsub("%s+", "")
        handle:close()
        if venv ~= "" then
          return venv .. "/bin/python"
        end
      end
      
      -- Check for .venv in current directory
      local local_venv = vim.fn.getcwd() .. "/.venv"
      if vim.fn.isdirectory(local_venv) == 1 then
        return local_venv .. "/bin/python"
      end
      
      -- Fallback to system python
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
          pythonPath = get_python_path(),
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

    ------------------------------------------------------------------
    -- Enable servers
    ------------------------------------------------------------------
    vim.lsp.enable({
      "pyright",
      "ruff",
      "lua_ls",
      "zls",
    })

    ------------------------------------------------------------------
    -- Auto-restart Python LSP when entering Python files
    ------------------------------------------------------------------
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.py",
      callback = function()
        local current_python = get_python_path()
        -- Restart pyright with new Python path if it changed
        vim.lsp.stop_client("pyright")
        vim.lsp.start({
          name = "pyright",
          cmd = { "pyright-langserver", "--stdio" },
          root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git" }),
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            python = {
              pythonPath = current_python,
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        })
      end,
    })
  end,
}

