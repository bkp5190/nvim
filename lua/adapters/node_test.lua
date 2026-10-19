-- neotest adapter for Node's built-in `node:test` runner (no Jest/Vitest needed).
-- Claims only files that import node:test, so it never competes with neotest-jest.
local lib = require("neotest.lib")

---@class neotest.Adapter
local M = { name = "neotest-node-test" }

M.root = lib.files.match_root_pattern("package.json")

function M.filter_dir(name)
  return name ~= "node_modules" and name ~= "ios" and name ~= "android" and name ~= "dist"
end

local exts = { mjs = true, cjs = true, js = true, mts = true, cts = true, ts = true }

function M.is_test_file(path)
  if not path then
    return false
  end
  local ext = path:match("%.([%w]+)$")
  if not (ext and exts[ext]) or not path:match("%.test%.") and not path:match("%.spec%.") then
    return false
  end
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local head = f:read(4096) or ""
  f:close()
  return head:find("node:test", 1, true) ~= nil
end

function M.discover_positions(path)
  local query = [[
    ;; describe('x', ...) / suite('x', ...)
    ((call_expression
      function: [
        (identifier) @_f
        (member_expression object: (identifier) @_f)
      ]
      arguments: (arguments . (string (string_fragment) @namespace.name) . (_))
      (#any-of? @_f "describe" "suite")
    )) @namespace.definition

    ;; test('x', ...) / it('x', ...) incl. test.skip / test.only / test.todo
    ((call_expression
      function: [
        (identifier) @_f
        (member_expression object: (identifier) @_f)
      ]
      arguments: (arguments . (string (string_fragment) @test.name) . (_))
      (#any-of? @_f "test" "it")
    )) @test.definition
  ]]
  return lib.treesitter.parse_positions(path, query, { nested_tests = true })
end

local function escape_pattern(s)
  return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?%{%}%|\\/]", "\\%0"))
end

local function node_args(results_path, extra)
  local args = {
    "--experimental-strip-types",
    "--test",
    "--test-reporter=junit",
    "--test-reporter-destination=" .. results_path,
    "--test-reporter=spec",
    "--test-reporter-destination=stdout",
  }
  vim.list_extend(args, extra or {})
  return args
end

function M.build_spec(args)
  local position = args.tree:data()
  local root = M.root(position.path) or vim.fn.getcwd()
  local results_path = vim.fn.tempname() .. ".xml"
  local extra = {}

  if position.type == "test" or position.type == "namespace" then
    table.insert(extra, "--test-name-pattern=^" .. escape_pattern(position.name) .. "$")
  end

  local target = position.path
  local context = { results_path = results_path, file = position.path }

  local spec = { cwd = root, context = context }

  if args.strategy == "dap" then
    -- Single process so the debugger sees the test code directly.
    table.insert(extra, "--test-isolation=none")
    local rt = node_args(results_path, extra)
    spec.strategy = {
      type = "pwa-node",
      request = "launch",
      name = "Debug node:test",
      runtimeExecutable = "node",
      runtimeArgs = rt,
      program = target,
      cwd = root,
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
      console = "integratedTerminal",
    }
    return spec
  end

  local command = { "node" }
  vim.list_extend(command, node_args(results_path, extra))
  if position.type == "dir" then
    -- Run every node:test file found below this directory.
    local files = vim.fs.find(function(name, dir)
      return M.is_test_file(vim.fs.joinpath(dir, name))
    end, { path = position.path, type = "file", limit = math.huge })
    vim.list_extend(command, files)
  else
    table.insert(command, target)
  end
  spec.command = command
  return spec
end

local function unxml(s)
  return (
    s:gsub("&#10;", "\n")
      :gsub("&#13;", "\r")
      :gsub("&#9;", "\t")
      :gsub("&lt;", "<")
      :gsub("&gt;", ">")
      :gsub("&quot;", '"')
      :gsub("&apos;", "'")
      :gsub("&amp;", "&")
  )
end

local function attr(tag, key)
  local v = tag:match("%s" .. key .. '="([^"]*)"')
  return v and unxml(v) or nil
end

function M.results(spec, result, tree)
  local results = {}
  local ok, content = pcall(lib.files.read, spec.context.results_path)
  if not ok or not content or content == "" then
    -- Process died before the reporter wrote anything (e.g. syntax error).
    for _, node in tree:iter_nodes() do
      local d = node:data()
      results[d.id] =
        { status = "failed", output = result.output, short = "node produced no report" }
    end
    return results
  end

  -- Index tree positions by (file, name) so reported cases map to ids.
  local by_name = {}
  for _, node in tree:iter_nodes() do
    local d = node:data()
    if d.type == "test" then
      by_name[d.path .. "\0" .. d.name] = d
    end
  end

  local suite_status = {}
  local pos = 1
  while true do
    local s, e, tag = content:find("<testcase(.-)>", pos)
    if not s then
      break
    end
    local self_closing = tag:sub(-1) == "/"
    local body_end = e
    local body = ""
    if not self_closing then
      local _, ce = content:find("</testcase>", e, true)
      body_end = ce or e
      body = content:sub(e + 1, (ce or e) - 11)
    end
    local name, file = attr(tag, "name"), attr(tag, "file")
    local d = name and file and by_name[file .. "\0" .. name]
    if d then
      local status, errors = "passed", nil
      if body:find("<skipped", 1, true) then
        status = "skipped"
      elseif body:find("<failure", 1, true) then
        status = "failed"
        local msg = attr(body:match("<failure(.-)>") or "", "message") or "failed"
        local detail = unxml(body:match("<failure.->(.-)</failure>") or "")
        local line = detail:match(vim.pesc(vim.fs.basename(file)) .. ":(%d+):%d+")
        errors = { { message = msg, line = line and (tonumber(line) - 1) or nil } }
      end
      results[d.id] =
        { status = status, errors = errors, short = errors and errors[1].message or nil }
      suite_status[d.path] = suite_status[d.path] or {}
      table.insert(suite_status[d.path], status)
    end
    pos = body_end + 1
  end

  -- Roll up namespaces/files/dirs from their children.
  local function rollup(node)
    local d = node:data()
    if results[d.id] and d.type == "test" then
      return results[d.id].status
    end
    local worst, any = "skipped", false
    for _, child in node:iter_nodes() do
      if child ~= node and child:data().type == "test" then
        local r = results[child:data().id]
        if r then
          any = true
          if r.status == "failed" then
            worst = "failed"
          elseif r.status == "passed" and worst ~= "failed" then
            worst = "passed"
          end
        end
      end
    end
    return any and worst or nil
  end
  for _, node in tree:iter_nodes() do
    local d = node:data()
    if d.type ~= "test" then
      local status = rollup(node)
      if status then
        results[d.id] = { status = status }
      end
    end
  end

  -- Attach the full terminal output to the top node for the output viewer.
  local root_id = tree:data().id
  results[root_id] = results[root_id] or { status = result.code == 0 and "passed" or "failed" }
  results[root_id].output = result.output
  return results
end

setmetatable(M, {
  __call = function()
    return M
  end,
})

return M
