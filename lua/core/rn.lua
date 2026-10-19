-- React Native / Expo tasks: Metro, iOS builds, simulators, logs, DevTools,
-- and typecheck/lint results in quickfix. Keymaps live under <leader>n.
local project = require("core.project")
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "React Native" })
end

local function root()
  return project.root()
end

local function term(cmd, opts)
  opts = opts or {}
  return require("snacks").terminal.get(cmd, {
    cwd = root(),
    create = opts.create ~= false,
    interactive = opts.interactive,
    auto_close = false,
    win = { position = opts.position or "bottom", height = 0.35 },
  })
end

------------------------------------------------------------------
-- Metro
------------------------------------------------------------------
local metro_cmd

local function port_in_use(port)
  return vim.system({ "lsof", "-ti", "tcp:" .. port }, { text = true }):wait().stdout:match("%d")
    ~= nil
end

-- 8081 may belong to another checkout's bundler (see AGENTS.md); don't reuse it blindly.
function M.metro_port()
  if vim.g.rn_metro_port then
    return vim.g.rn_metro_port
  end
  if not port_in_use(8081) then
    return 8081
  end
  local body =
    vim.system({ "curl", "-s", "-m", "2", "http://localhost:8081/" }, { text = true }):wait().stdout
  if body and body:find(root(), 1, true) then
    return 8081
  end
  notify("Port 8081 is another project's Metro; using 8090", vim.log.levels.WARN)
  return 8090
end

function M.metro_start()
  local port = M.metro_port()
  metro_cmd = ("npx expo start --dev-client --port %d"):format(port)
  term(metro_cmd, { interactive = true })
end

function M.metro_toggle()
  if metro_cmd then
    term(metro_cmd, { create = false, interactive = true })
  else
    M.metro_start()
  end
end

-- Expo's CLI is interactive: r reload, m dev menu, j React Native DevTools, i open iOS.
local function metro_key(key, label)
  return function()
    local t = metro_cmd and term(metro_cmd, { create = false })
    local chan = t and t.buf and vim.bo[t.buf].channel
    if not chan or chan == 0 then
      return notify("Metro isn't running (<leader>ns to start it)", vim.log.levels.WARN)
    end
    vim.fn.chansend(chan, key)
    notify(label)
  end
end

function M.metro_stop()
  local t = metro_cmd and term(metro_cmd, { create = false })
  if t then
    t:close()
    if t.buf and vim.api.nvim_buf_is_valid(t.buf) then
      vim.api.nvim_buf_delete(t.buf, { force = true })
    end
  end
  metro_cmd = nil
end

------------------------------------------------------------------
-- Simulators / iOS
------------------------------------------------------------------
local function simulators()
  local out = vim
    .system({ "xcrun", "simctl", "list", "devices", "available", "-j" }, { text = true })
    :wait()
  local ok, data = pcall(vim.json.decode, out.stdout or "")
  local list = {}
  if ok then
    for runtime, devices in pairs(data.devices or {}) do
      local ver = runtime:match("iOS%-([%d%-]+)$")
      if ver then
        for _, d in ipairs(devices) do
          if d.name:match("^iPhone") or d.name:match("^iPad") then
            table.insert(
              list,
              { name = d.name, udid = d.udid, state = d.state, os = ver:gsub("%-", ".") }
            )
          end
        end
      end
    end
  end
  table.sort(list, function(a, b)
    if (a.state == "Booted") ~= (b.state == "Booted") then
      return a.state == "Booted"
    end
    return a.os .. a.name > b.os .. b.name
  end)
  return list
end

function M.pick_simulator(cb)
  local list = simulators()
  if #list == 0 then
    return notify("No iOS simulators found (is Xcode installed?)", vim.log.levels.ERROR)
  end
  vim.ui.select(list, {
    prompt = "iOS simulator",
    format_item = function(d)
      return ("%s%s  (iOS %s)"):format(d.state == "Booted" and "● " or "  ", d.name, d.os)
    end,
  }, function(choice)
    if choice then
      vim.g.rn_simulator = choice.udid
      cb(choice)
    end
  end)
end

local function run_ios(sim)
  local cmd = "npx expo run:ios --port " .. M.metro_port()
  if sim then
    cmd = cmd .. " --device " .. sim.udid
  end
  term(cmd)
end

-- Build + install the custom dev client on the last-used (or chosen) simulator.
function M.run_ios()
  if not project.is_expo() then
    return notify("Not an Expo project (no app.json / node_modules/.bin/expo)", vim.log.levels.WARN)
  end
  if vim.g.rn_simulator then
    run_ios({ udid = vim.g.rn_simulator })
  else
    M.pick_simulator(run_ios)
  end
end

function M.run_ios_pick()
  M.pick_simulator(run_ios)
end

function M.run_ios_device()
  term("npx expo run:ios --device --port " .. M.metro_port())
end

local function process_name()
  local proj = vim.fn.glob(vim.fs.joinpath(root(), "ios", "*.xcodeproj"), false, true)[1]
  return proj and vim.fn.fnamemodify(proj, ":t:r") or nil
end

function M.sim_logs()
  local name = process_name()
  local pred = name and ('process == "%s"'):format(name) or 'processImagePath CONTAINS "Containers"'
  term(
    ("xcrun simctl spawn booted log stream --level debug --predicate '%s'"):format(pred),
    { position = "right" }
  )
end

function M.open_url()
  vim.ui.input({ prompt = "Deep link: ", default = "stockmatch://" }, function(url)
    if url and url ~= "" then
      local r = vim.system({ "xcrun", "simctl", "openurl", "booted", url }, { text = true }):wait()
      notify(
        r.code == 0 and ("Opened " .. url) or (r.stderr or "failed"),
        r.code == 0 and nil or vim.log.levels.ERROR
      )
    end
  end)
end

function M.screenshot()
  local path = vim.fn.expand("~/Desktop/sim-" .. os.date("%Y%m%d-%H%M%S") .. ".png")
  local r = vim
    .system({ "xcrun", "simctl", "io", "booted", "screenshot", path }, { text = true })
    :wait()
  notify(
    r.code == 0 and ("Saved " .. path) or (r.stderr or "failed"),
    r.code == 0 and nil or vim.log.levels.ERROR
  )
end

------------------------------------------------------------------
-- Quickfix checks
------------------------------------------------------------------
local function async_check(label, cmd, parse)
  notify(label .. "...")
  vim.system(cmd, { cwd = root(), text = true }, function(r)
    vim.schedule(function()
      local items = parse(r.stdout or "", r.stderr or "")
      vim.fn.setqflist({}, " ", { title = label, items = items })
      if #items > 0 then
        vim.cmd("copen")
        notify(("%s: %d issue(s)"):format(label, #items), vim.log.levels.WARN)
      else
        vim.cmd("cclose")
        notify(label .. ": clean ✓")
      end
    end)
  end)
end

function M.typecheck()
  async_check("tsc --noEmit", { "npx", "tsc", "--noEmit", "--pretty", "false" }, function(out)
    local items = {}
    for line in out:gmatch("[^\n]+") do
      local file, l, c, kind, msg = line:match("^(.-)%((%d+),(%d+)%): (%a+) (.*)$")
      if file then
        table.insert(items, {
          filename = vim.fs.joinpath(root(), file),
          lnum = tonumber(l),
          col = tonumber(c),
          type = kind == "error" and "E" or "W",
          text = msg,
        })
      end
    end
    return items
  end)
end

function M.lint()
  async_check("eslint", { "npx", "eslint", ".", "-f", "json" }, function(out)
    local items = {}
    local ok, data = pcall(vim.json.decode, out)
    if ok then
      for _, f in ipairs(data) do
        for _, m in ipairs(f.messages) do
          table.insert(items, {
            filename = f.filePath,
            lnum = m.line or 1,
            col = m.column or 1,
            type = m.severity == 2 and "E" or "W",
            text = (m.message or "") .. (m.ruleId and (" [" .. m.ruleId .. "]") or ""),
          })
        end
      end
    end
    return items
  end)
end

function M.npm(script)
  return function()
    term("npm run " .. script)
  end
end

function M.cmd(cmd)
  return function()
    term(cmd)
  end
end

------------------------------------------------------------------
-- Keymaps
------------------------------------------------------------------
local map = function(lhs, fn, desc)
  vim.keymap.set("n", lhs, fn, { desc = desc })
end
map("<leader>ns", M.metro_toggle, "Metro: start / show")
map("<leader>nx", M.metro_stop, "Metro: stop")
map("<leader>nr", metro_key("r", "Reload app"), "App: reload JS")
map("<leader>nm", metro_key("m", "Dev menu"), "App: dev menu")
map(
  "<leader>nj",
  metro_key("j", "Opening React Native DevTools"),
  "App: React Native DevTools (debugger)"
)
map("<leader>ni", M.run_ios, "iOS: build & run (dev client)")
map("<leader>nI", M.run_ios_pick, "iOS: pick simulator, build & run")
map("<leader>nd", M.run_ios_device, "iOS: build & run on device")
map("<leader>nl", M.sim_logs, "iOS: simulator logs")
map("<leader>nu", M.open_url, "iOS: open deep link")
map("<leader>np", M.screenshot, "iOS: simulator screenshot")
map("<leader>nc", M.typecheck, "Typecheck → quickfix")
map("<leader>ne", M.lint, "Lint → quickfix")
map("<leader>nT", M.npm("test"), "Run full test suite (npm test)")
map("<leader>nD", M.cmd("npx expo-doctor"), "expo-doctor")
map("<leader>nk", M.cmd("npx expo install --check"), "expo install --check")

vim.api.nvim_create_user_command("RNSimulator", M.run_ios_pick, {})
vim.api.nvim_create_user_command("RNMetro", M.metro_toggle, {})

return M
