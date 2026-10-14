{self, ...}: {
  flake.wrappers.ghostty = {
    pkgs,
    lib,
    ...
  }: let
    packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [self.baseWrappers.ghostty];

    settings = {
      language = "es";
      initial-command = "${lib.getExe packages.bash} -lc ${lib.escapeShellArg "tmux new-session -A -s main"}";
      command = lib.getExe packages.bash;
      font-family = "Hack Nerd Font";
      font-size = 13;
      theme = "dark:Vercel,light:Catppuccin Latte";
    };
  };
}
