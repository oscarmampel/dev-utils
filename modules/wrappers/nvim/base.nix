{...}: {
  flake.modules.nvim.base = {...}: {
    config.vim = {
      spellcheck = {
        enable = true;
        languages = ["es" "en"];
      };
      statusline.lualine.enable = true;
      telescope.enable = true;
      autopairs.nvim-autopairs.enable = true;
      comments.comment-nvim.enable = true;
      binds = {
        cheatsheet.enable = true;
        hardtime-nvim.enable = true;
      };
      augroups = [
        {
          name = "tabBehavior";
          clear = true;
        }
      ];
      lsp.formatOnSave = true;
      autocmds = [
        {
          enable = true;
          event = ["FileType"];
          pattern = ["*"];
          group = "tabBehavior";
          command = "setlocal tabstop=8 shiftwidth=8 expandtab";
        }
      ];
    };
  };
}
