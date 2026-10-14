{...}: {
  flake.modules.nvim.nix = {...}: {
    config.vim = {
      diagnostics.enable = true;
      formatter.conform-nvim = {
        enable = true;
        presets.alejandra.enable = true;
        setupOpts = {
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
      };
      languages.nix = {
        format.enable = true;
        enable = true;
        extraDiagnostics.enable = true;
        lsp = {
          enable = true;
        };
        treesitter.enable = true;
      };
      augroups = [
        {
          name = "tabBehavior";
          clear = true;
        }
      ];
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["nix"];
          group = "tabBehavior";
          command = "setlocal tabstop=2 shiftwidth=2 expandtab";
        }
      ];
    };
  };
}
