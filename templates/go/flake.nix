{
  description = "Go development shell";
  inputs = {
    dev-utils.url = "github:oscarmampel/dev-utils";
    container-devshell.url = "github:oscarmampel/devenv";
    container-devshell.inputs.nixpkgs.follows = "nixpkgs";
    container-devshell.inputs.flake-parts.follows = "flake-parts";
    nixpkgs.follows = "dev-utils/nixpkgs";
    flake-parts.follows = "dev-utils/flake-parts";
  };
  outputs = inputs @ {
    dev-utils,
    container-devshell,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [container-devshell.flakeModules.containerDevShell dev-utils.flakeModules.development];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {pkgs, ...}: {
        devshell.packages = [pkgs.go pkgs.gopls pkgs.gotools pkgs.go-tools];
      };
    };
}
