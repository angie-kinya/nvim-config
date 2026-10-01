return {
  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install({
        "bash", "css", "diff", "dockerfile", "gitcommit", "go", "gomod", "gosum", "gowork",
        "html", "javascript", "json", "lua", "markdown", "markdown_inline", "php",
        "python", "regex", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
}
