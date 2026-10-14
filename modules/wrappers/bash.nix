{self, ...}: {
  flake.wrappers.bash = {
    config,
    pkgs,
    lib,
    wlib,
    ...
  }: let
    packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [wlib.modules.default];
    options = {
      bash.extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        description = "List of packages available inside the system shell";
        default = [
          pkgs.ripgrep # Fast recursive text search.
          pkgs.bat # Cat replacement with syntax highlighting.
          pkgs.curl # HTTP client for requests and downloads.
          pkgs.wget # Non-interactive file downloader.
          pkgs.fd # Fast and ergonomic find replacement.
          pkgs.eza # Modern ls replacement with colors and Git info.
          pkgs.jq # Command-line JSON processor.
          pkgs.yq # Command-line YAML, TOML, XML, and JSON processor.
          pkgs.dua # Disk usage analyzer.
          pkgs.dust # Interactive disk usage viewer.
          pkgs.duf # Disk and mount overview.
          pkgs.procs # Modern ps replacement.
          pkgs.htop # Interactive process viewer.
          pkgs.tree # Directory tree viewer.
          packages.git # Version control CLI.
          pkgs.file # File type detection.
          pkgs.which # Locate commands in PATH.
          pkgs.zip # Create ZIP archives.
          pkgs.unzip # Extract ZIP archives.
          pkgs.sops
          pkgs.age
          packages.tmux # Terminal multiplexer used by Ghostty sessions.
          packages.fish # Interactive shell launched inside tmux.
          packages.codex # Codex CLI wrapper.
          packages.neovim # Default terminal editor.
        ];
      };
    };
    config = {
      package = pkgs.bashInteractive;
      runtimePkgs = config.bash.extraPackages;
      env = {
        EDITOR = lib.getExe packages.neovim;
        VISUAL = lib.getExe packages.neovim;
      };
    };
  };
}
