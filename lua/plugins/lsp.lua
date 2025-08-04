return {
  "neovim/nvim-lspconfig",  -- the plugin repo
  config = function()
    -- Setup nvim-cmp capabilities for LSP
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    -- Define your LSP servers
    local servers = {
      pyright = {},    -- Python LSP
      gopls = {},      -- Go LSP
      ruff = {},       -- Optional Python linter LSP
      lua_language_server = {},
      lua_ls = {       -- Lua LSP for config
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            completion = { callSnippet = "Replace" },
            diagnostics = { disable = { "missing-fields" } },
            workspace = {
              checkThirdParty = false,
              library = {
                "${3rd}/luv/library",
                unpack(vim.api.nvim_get_runtime_file("", true)),
              },
            },
            format = { enable = false },
          },
        },
      },
    }

    -- Setup each server with capabilities
    for name, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
      require("lspconfig")[name].setup(config)
    end

    -- LSP attach autocmd for keymaps and highlights
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local map = function(keys, func, desc, modes)
          modes = modes or "n"
          vim.keymap.set(modes, keys, func, { buffer = event.buf, desc = desc })
        end

        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>re", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
            callback = function(ev)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
            end,
          })
        end

        -- Toggle inlay hints if supported
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    -- Format Python files with black on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.py",
      callback = function()
        vim.cmd("silent! !black --fast " .. vim.fn.expand("%"))
      end,
    })

    -- Optional: Keymap to format manually with black
    vim.keymap.set("n", "<leader>f", function()
      vim.cmd("silent! !black --fast " .. vim.fn.expand("%"))
    end, { desc = "Format current file with black" })
  end,
}

