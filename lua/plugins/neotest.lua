return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/neotest-python",
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local neotest = require("neotest")

		-- Clean up diagnostics
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				format = function(diagnostic)
					local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
					return message
				end,
			},
		}, neotest_ns)

		-- Setup neotest with Python adapter
		neotest.setup({
			adapters = {
				require("neotest-python")({
					args = { "--verbose" },
					runner = "pytest",
					python = function()
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
					end,
				}),
			},
		})

		local map = vim.keymap.set
		map("n", "<leader>tt", function()
			neotest.run.run(vim.fn.expand("%"))
		end, { desc = "Run current file tests" })
		map("n", "<leader>tr", function()
			neotest.run.run()
		end, { desc = "Run nearest test" })
		map("n", "<leader>ta", function()
			neotest.run.run(vim.fn.getcwd())
		end, { desc = "Run all tests" })
		map("n", "<leader>td", function()
			neotest.run.run({ strategy = "dap" })
		end, { desc = "Debug nearest test" })
		map("n", "<leader>to", function()
			neotest.output.open({ enter = true, auto_close = true })
		end, { desc = "Toggle test output" })
		map("n", "<leader>tO", function()
			neotest.output_panel.toggle()
		end, { desc = "Toggle test output panel" })
		map("n", "<leader>ts", function()
			neotest.summary.toggle()
		end, { desc = "Toggle test summary" })
		map("n", "<leader>tq", function()
			neotest.run.stop()
		end, { desc = "Stop running tests" })
		map("n", "]t", function()
			neotest.jump.next({ status = "failed" })
		end, { desc = "Next failed test" })
		map("n", "[t", function()
			neotest.jump.prev({ status = "failed" })
		end, { desc = "Previous failed test" })
	end,
}
