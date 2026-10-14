{...}: {
  flake.modules.nvim.theme = {...}: {
    config.vim.theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };
  };
}
