return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      -- this runs for all LSPs
      ["*"] = function(_)
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client == nil then
              return
            end
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(false)
            end
          end,
        })
      end,
    },
  },
}
