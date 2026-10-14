{self, ...}: {
  flake.wrappers.git = {
    pkgs,
    lib,
    wlib,
    config,
    ...
  }: {
    imports = [wlib.wrapperModules.git];
    options = {
      ignoreFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of file patterns that should be ingored in all projects";
        example = [
          ".agents"
          ".codex"
        ];
        default = [
          "/.agents"
          "/.codex"
          "/.direnv"
          "/.envrc"
        ];
      };
    };
    config = {
      constructFiles.ignoreFile = {
        content = builtins.concatStringsSep "\n" config.ignoreFiles;
        relPath = "share/.gitignore";
      };
      runShell = [
        ''
          if [ -n "''${GIT_ENV_FILE:-}" ]; then
            if [ ! -r "$GIT_ENV_FILE" ]; then
              echo "GIT_ENV_FILE is set but not readable: $GIT_ENV_FILE" >&2
              exit 1
            fi

            set -a
            . "$GIT_ENV_FILE"
            set +a
          fi
        ''
      ];
      settings = {
        init.defaultBranch = "main";
        core = {
          excludesFile = config.constructFiles.ignoreFile.path;
        };
        credential = {
          credentialStore = "secretservice";
          helper = lib.getExe pkgs.git-credential-manager;
        };
      };
    };
  };
}
