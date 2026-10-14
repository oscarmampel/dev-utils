{...}: {
  flake.baseWrappers.direnv = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: let
    tomlFormat = pkgs.formats.toml {};

    textOrPath = lib.types.either lib.types.lines lib.types.path;

    readText = value:
      if lib.isPath value
      then builtins.readFile value
      else value;

    direnvConfigDir = dirOf config.constructFiles.generatedConfig.path;
    direnvExe = lib.getExe config.package;
    generatedConfig = tomlFormat.generate "direnv.toml" config.settings;

    libFiles =
      lib.mapAttrs' (
        name: value:
          lib.nameValuePair "lib-${name}" {
            content = readText value;
            relPath = "direnv-config/direnv/lib/${name}.sh";
          }
      )
      config.lib;
  in {
    imports = [wlib.modules.default];

    options = {
      settings = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        description = "direnv.toml settings generated from Nix.";
      };

      direnvrc = lib.mkOption {
        type = lib.types.nullOr textOrPath;
        default = null;
        description = "Bash code written to direnv/direnvrc and loaded before every .envrc.";
      };

      lib = lib.mkOption {
        type = lib.types.attrsOf textOrPath;
        default = {};
        description = "Bash extension files written to direnv/lib/*.sh and loaded before every .envrc.";
      };
    };

    config = {
      package = pkgs.direnv;
      constructFiles =
        {
          generatedConfig = {
            builder = ''cp ${lib.escapeShellArg generatedConfig} "$2"'';
            relPath = "direnv-config/direnv/direnv.toml";
          };
        }
        // lib.optionalAttrs (config.direnvrc != null) {
          direnvrc = {
            content = readText config.direnvrc;
            relPath = "direnv-config/direnv/direnvrc";
          };
        }
        // libFiles;
      env = {
        DIRENV_CONFIG = direnvConfigDir;
      };
      runShell = [
        ''
          if [ "''${1:-}" = "hook" ]; then
            real_direnv=${lib.escapeShellArg direnvExe}
            hook_output="$("$real_direnv" "$@")"
            hook_status=$?
            if [ "$hook_status" -ne 0 ]; then
              printf '%s\n' "$hook_output"
              exit "$hook_status"
            fi

            printf '%s\n' "''${hook_output//$real_direnv/$0}"
            exit 0
          fi
        ''
      ];
      meta.description = "direnv wrapper with declarative XDG configuration";
    };
  };
}
