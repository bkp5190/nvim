return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dap-go").setup()
		require("dapui").setup()
		
		-- Setup Python debugging with dynamic path detection
		local function get_python_path()
			local uv_venv = os.getenv("VIRTUAL_ENV")
			if uv_venv and uv_venv ~= "" then
				return uv_venv .. "/bin/python"
			end
			
			local handle = io.popen("poetry env info -p 2>/dev/null")
			if handle then
				local venv = handle:read("*a"):gsub("%s+", "")
				handle:close()
				if venv ~= "" then
					return venv .. "/bin/python"
				end
			end
			
			local local_venv = vim.fn.getcwd() .. "/.venv"
			if vim.fn.isdirectory(local_venv) == 1 then
				return local_venv .. "/bin/python"
			end
			
			return "python3"
		end
		
		require("dap-python").setup(get_python_path(), {
			console = "integratedTerminal",
		})
		-- Auto open/close UI
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})
		vim.keymap.set("n", "<leader>ds", dap.step_over, {})
		vim.keymap.set("n", "<leader>di", dap.step_into, {})
		vim.keymap.set("n", "<leader>do", dap.step_out, {})
		vim.keymap.set("n", "<leader>dr", dap.repl.open, {})
	end,
}
