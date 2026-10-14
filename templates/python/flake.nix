{
  description = "Python development shell";

  inputs = {
    dev-utils.url = "github:oscarmampel/dev-utils";
    container-devshell.url = "github:oscarmampel/devenv";
    container-devshell.inputs.nixpkgs.follows = "nixpkgs";
    container-devshell.inputs.flake-parts.follows = "flake-parts";
    flake-parts.follows = "dev-utils/flake-parts";
    nixpkgs.follows = "dev-utils/nixpkgs";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  outputs = inputs @ {
    container-devshell,
    dev-utils,
    flake-parts,
    nixpkgs-python,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [container-devshell.flakeModules.containerDevShell dev-utils.flakeModules.development];
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        pythonVersion = pkgs.lib.strings.trim (builtins.readFile ./.python-version);
      in {
        devshell.packages = [nixpkgs-python.packages.${system}.${pythonVersion}];
      };
    };
}
