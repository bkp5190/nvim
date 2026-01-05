return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format()
			end,
			mode = "",
			desc = "Format file",
		},
	},
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black", "ruff_format" },
			go = { "gopls" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = function(bufnr)
			local filepath = vim.api.nvim_buf_get_name(bufnr)
			local result = vim.fn.system("git ls-files --error-unmatch " .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
			if vim.v.shell_error == 0 then
				return false
			end
			return { timeout_ms = 500 }
		end,
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
