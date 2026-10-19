return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = { select = { lookahead = true }, move = { set_jumps = true } },
  config = function(_, opts)
    require("nvim-treesitter-textobjects").setup(opts)
    for key, query in pairs({
      af = "@function.outer",
      ["if"] = "@function.inner",
      ac = "@class.outer",
      ic = "@class.inner",
      aa = "@parameter.outer",
      ia = "@parameter.inner",
    }) do
      vim.keymap.set({ "x", "o" }, key, function()
        require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
      end, { desc = "Select " .. query })
    end
    for key, query in pairs({ ["]f"] = "@function.outer", ["]c"] = "@class.outer" }) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        require("nvim-treesitter-textobjects.move").goto_next_start(query, "textobjects")
      end, { desc = "Next " .. query })
    end
    for key, query in pairs({ ["[f"] = "@function.outer", ["[c"] = "@class.outer" }) do
      vim.keymap.set({ "n", "x", "o" }, key, function()
        require("nvim-treesitter-textobjects.move").goto_previous_start(query, "textobjects")
      end, { desc = "Previous " .. query })
    end
  end,
}
