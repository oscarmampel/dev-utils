{lib, ...}: {
  flake.modules.nvim.ruby = {...}: {
    config.vim = {
      languages.ruby = {
        enable = true;
        lsp = {
          enable = true;
          servers = ["ruby-lsp"];
        };
        format.enable = false;
        extraDiagnostics.enable = false;
        treesitter.enable = true;
      };

      lsp.servers.ruby-lsp = {
        cmd = lib.mkForce ["ruby" "-S" "bundle" "exec" "ruby-lsp"];
        root_markers = ["Gemfile" ".ruby-version" ".git"];
        init_options.formatter = "auto";
      };

      augroups = [
        {
          name = "rubyBehavior";
          clear = true;
        }
      ];
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["ruby"];
          group = "rubyBehavior";
          command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
        }
        {
          enable = true;
          event = ["FileType"];
          pattern = ["ruby"];
          group = "rubyBehavior";
          command = "setlocal colorcolumn=89,120";
        }
      ];
    };
  };
}
