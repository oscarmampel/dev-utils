{...}:
{
  flake.modules.nvim.insights = { ... }:
  {
    config.vim = {
      binds.whichKey.enable = true;
      lsp.lspkind.enable = true;
      autocomplete.blink-cmp.enable = true;
      luaConfigRC = {
        inlineDiagnostics = "
          vim.diagnostic.config({ virtual_lines = { current_line = true } })
        ";
      };
    };
  };
}
