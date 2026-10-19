local M = {}
local diagnosed_tick = {}

function M.on_diagnostics(err, params, ctx)
  if not err and params then
    local bufnr = vim.uri_to_bufnr(params.uri)
    if
      vim.api.nvim_buf_is_loaded(bufnr)
      and (params.version == nil or params.version == vim.lsp.util.buf_versions[bufnr])
    then
      diagnosed_tick[bufnr] = vim.api.nvim_buf_get_changedtick(bufnr)
    end
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(err, params, ctx)
end

-- TypeScript exposes deterministic source actions for missing imports.
-- Python uses auto-import completions; Ruff sorts existing imports in Conform.
function M.on_save(bufnr)
  -- ESLint's official fix-all command applies project-configured, fixable rules.
  -- Run before TypeScript imports and Conform so Prettier owns final formatting.
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })) do
    local response, err = client:request_sync("workspace/executeCommand", {
      command = "eslint.applyAllFixes",
      arguments = {
        {
          uri = vim.uri_from_bufnr(bufnr),
          version = vim.lsp.util.buf_versions[bufnr],
        },
      },
    }, 2000, bufnr)
    if err or (response and response.err) then
      vim.notify(
        "ESLint save fixes failed: " .. vim.inspect(err or response.err),
        vim.log.levels.WARN
      )
    end
  end
  -- Re-sorting imports restyles existing code, so only do it in Prettier projects.
  local kinds = { "source.addMissingImports.ts" }
  if require("core.project").uses_prettier(require("core.project").root(bufnr)) then
    table.insert(kinds, "source.organizeImports")
  end
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "vtsls" })) do
    for _, kind in ipairs(kinds) do
      local response
      local function request()
        response = client:request_sync("textDocument/codeAction", {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
          context = { only = { kind }, diagnostics = {} },
        }, 1500, bufnr)
        return not response or response.err or (response.result and #response.result > 0)
      end
      request() -- Flush pending document changes before awaiting diagnostics.
      if
        kind == "source.addMissingImports.ts"
        and diagnosed_tick[bufnr] ~= vim.api.nvim_buf_get_changedtick(bufnr)
      then
        -- Source actions depend on current semantic diagnostics, especially on
        -- the first save after opening or changing a document.
        vim.wait(1200, function()
          return diagnosed_tick[bufnr] == vim.api.nvim_buf_get_changedtick(bufnr)
        end, 30)
        request()
      end
      for _, action in ipairs(response and response.result or {}) do
        if not action.disabled then
          if action.data and client:supports_method("codeAction/resolve") then
            local resolved = client:request_sync("codeAction/resolve", action, 2500, bufnr)
            action = resolved and resolved.result or action
          end
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
          end
          if action.command then
            local command = type(action.command) == "table" and action.command or action
            client:request_sync("workspace/executeCommand", command, 2500, bufnr)
          end
        end
      end
    end
  end
end

return M
