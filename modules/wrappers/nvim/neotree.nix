{...}: {
  flake.modules.nvim.neotree = {...}: {
    config.vim = {
      visuals.nvim-web-devicons.enable = true;
      filetree.neo-tree = {
        enable = true;
        setupOpts = {
          reveal = true;
          filesystem = {
            filtered_items = {
              visible = true;
              hide_gitignored = true;
              never_show = [".git"];
            };
          };
        };
      };
    };
  };
}
