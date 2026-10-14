{
  self,
  inputs,
  ...
}: {
  flake.wrappers.codex = {pkgs, ...}: {
    imports = [self.baseWrappers.codex];

    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex;
    settings = {};
    profiles = {};
    context = "";
    hooks = {};
    skills = {};
    rules = {};
    stateDirectory = null;
  };
}
