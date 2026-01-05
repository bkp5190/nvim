return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    vim.g.copilot_proxy_strict_ssl = false
  end,
  lazy = false,
}
