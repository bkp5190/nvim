return {
  "neovim/nvim-lspconfig",
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())

    -- LSP attach callback for keymaps and highlights
    local on_attach = function(client, bufnr)
      local map = function(keys, func, desc, modes)
        modes = modes or "n"
        vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
      end

      map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
      map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
      map("<leader>re", vim.lsp.buf.rename, "[R]e[n]ame")
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
      map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = bufnr,
          group = hl_group,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = bufnr,
          group = hl_group,
          callback = vim.lsp.buf.clear_references,
        })
      end

      if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map("<leader>th", function()
          vim.lsp.inlay_hint.toggle({ bufnr = bufnr })
        end, "[T]oggle Inlay [H]ints")
      end
    end

    -- Detect Poetry virtual environment
    local function get_poetry_venv()
      local handle = io.popen("poetry env info -p 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        result = result:gsub("%s+", "")
        if result ~= "" then
          return result
        end
      end
      return nil
    end

    local poetry_venv = get_poetry_venv()
    local python_path = poetry_venv and (poetry_venv .. "/bin/python") or "python3"

    -- Define LSP servers
    local servers = {
      pyright = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          python = { pythonPath = python_path },
        },
      },
      ruff = { on_attach = on_attach, capabilities = capabilities },
      lua_ls = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            completion = { callSnippet = "Replace" },
            diagnostics = { disable = { "missing-fields" } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            format = { enable = false },
          },
        },
      },
    }

    -- Setup each server
    for name, cfg in pairs(servers) do
      require("lspconfig")[name].setup(cfg)
    end

    -- Format Python files with black on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.py",
      callback = function()
        vim.cmd("silent! !black --fast " .. vim.fn.expand("%"))
      end,
    })

    -- Manual formatting keymap
    vim.keymap.set("n", "<leader>f", function()
      vim.cmd("silent! !black --fast " .. vim.fn.expand("%"))
    end, { desc = "Format current file with black" })
  end,
}

