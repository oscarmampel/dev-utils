{...}: {
  flake.modules.nvim.go = {...}: {
    config.vim = {
      languages.go = {
        enable = true;
        lsp = {
          enable = true;
          servers = ["gopls"];
        };
        format = {
          enable = true;
          type = ["gofmt"];
        };
        treesitter.enable = true;
      };

      augroups = [
        {
          name = "goBehavior";
          clear = true;
        }
      ];
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["go" "gomod" "gowork"];
          group = "goBehavior";
          command = "setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab";
        }
      ];
    };
  };
}
