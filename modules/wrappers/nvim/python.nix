{lib, ...}: {
  flake.modules.nvim.python = {...}: {
    config.vim = {
      languages.python = {
        enable = true;
        lsp = {
          enable = true;
          servers = ["pyright"];
        };
        format = {
          enable = true;
          type = ["ruff"];
        };
        extraDiagnostics.enable = false;
        treesitter.enable = true;
      };

      lsp.servers.pyright.before_init = lib.generators.mkLuaInline ''
        function(_, config)
          -- Resolve the devshell interpreter at runtime, keeping its wrapper path.
          local python = vim.fn.exepath("python")
          if python == "" then
            python = vim.fn.exepath("python3")
          end
          if python ~= "" then
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python
          end
        end
      '';

      augroups = [
        {
          name = "pythonBehavior";
          clear = true;
        }
      ];
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["python"];
          group = "pythonBehavior";
          command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
        }
      ];
    };
  };
}
