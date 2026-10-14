{
  inputs,
  self,
  ...
}: {
  flake.wrappers.fish = {
    pkgs,
    lib,
    wlib,
    ...
  }: let
    packages = self.packages.${pkgs.stdenv.hostPlatform.system};
    agnosterTheme = pkgs.fetchFromGitHub {
      owner = "oh-my-fish";
      repo = "theme-agnoster";
      rev = "4c5518c89ebcef393ef154c9f576a52651400d27";
      hash = "sha256-OFESuesnfqhXM0aij+79kdxjp4xgCt28YwTrcwQhFMU=";
    };
    agnosterPlugin = pkgs.fishPlugins.buildFishPlugin {
      pname = "theme-agnoster";
      version = "2024-01-28";
      src = agnosterTheme;
    };
  in {
    imports = [self.baseWrappers.fish];
    config = {
      runtimePkgs = [
        pkgs.atuin
        packages.direnv
        packages.git
      ];
      env = {
        EDITOR = lib.getExe packages.neovim;
      };
      plugins = [
        agnosterPlugin
      ];
      functions =
        self.wrapperTemplates.fish.functions.direnv {}
        // self.wrapperTemplates.fish.functions.nix {}
        // self.wrapperTemplates.fish.functions.prompt {};
      configFile.content = ''
        set -g theme_display_user yes
        set -g theme_hide_hostname no
        set fish_private_mode
        fish_config theme choose "catppuccin-mocha"
        ${lib.getExe pkgs.atuin} init fish | source
        ${lib.getExe packages.direnv} hook fish | source
      '';
    };
  };
}
