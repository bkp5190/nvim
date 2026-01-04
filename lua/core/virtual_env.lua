local M = {}

function M.get_python_path()
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

function M.setup()
  vim.api.nvim_create_user_command("PythonEnv", function()
    local python_path = M.get_python_path()
    local env_name = "Unknown"
    
    if os.getenv("VIRTUAL_ENV") then
      env_name = "UV/venv: " .. os.getenv("VIRTUAL_ENV")
    else
      local handle = io.popen("poetry env info -p 2>/dev/null")
      if handle then
        local venv = handle:read("*a"):gsub("%s+", "")
        handle:close()
        if venv ~= "" then
          env_name = "Poetry: " .. venv
        end
      end
    end
    
    print("Current Python: " .. python_path)
    print("Environment: " .. env_name)
  end, { desc = "Show current Python environment" })
end

return M
