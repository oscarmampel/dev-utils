{lib, ...}: {
  flake.modules.nvim.rust = {...}: {
    config.vim = {
      languages.rust = {
        enable = true;
        lsp = {
          enable = true;
          servers = ["rust-analyzer"];
        };
        # Format through the LSP using rustfmt from the project's toolchain.
        format.enable = false;
        treesitter.enable = true;
      };

      # Keep nvf's workspace support, but obtain the server from the devshell.
      # Provide compatible rust-analyzer, cargo, rustc, rustfmt and rust-src there.
      lsp.servers.rust-analyzer.cmd = lib.mkForce ["rust-analyzer"];

      augroups = [
        {
          name = "rustBehavior";
          clear = true;
        }
      ];
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["rust"];
          group = "rustBehavior";
          command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
        }
      ];
    };
  };
}
