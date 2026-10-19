return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    spec = {
      { "<leader>a", group = "AI / terminal" },
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Debug" },
      { "<leader>f", group = "Files / format" },
      { "<leader>g", group = "Git" },
      { "<leader>n", group = "React Native / iOS" },
      { "<leader>p", group = "Python" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Tests / toggles" },
      { "<leader>tc", group = "Coverage" },
      { "<leader>9", group = "99 AI" },
    },
  },
}
