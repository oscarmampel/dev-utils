{self, ...}: {
  flake.flakeModules.default = self.flakeModules.development;
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [self'.packages.bash] ++ self'.packages.bash.configuration.bash.extraPackages;
      EDITOR = lib.getExe self'.packages.neovim;
      VISUAL = lib.getExe self'.packages.neovim;
      shellHook = ''
        exec ${lib.getExe self'.packages.bash} -ic ${lib.escapeShellArg "exec ${lib.getExe self'.packages.fish}"}
      '';
    };
  };

  flake.flakeModules.development = {
    perSystem = {
      lib,
      system,
      ...
    }: let
      utils = self.packages.${system};
    in {
      devshell = {
        packages = [utils.bash] ++ utils.bash.configuration.bash.extraPackages;
        env = {
          EDITOR = lib.getExe utils.neovim;
          VISUAL = lib.getExe utils.neovim;
        };
        interactiveShell = {
          package = utils.bash;
          executable = "bash";
          args = ["-ic" "exec ${lib.getExe utils.fish}"];
        };
      };
    };
  };
}
