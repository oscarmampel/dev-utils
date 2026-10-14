{...}: {
  flake.baseWrappers.codex = {
    config,
    lib,
    wlib,
    pkgs,
    ...
  }: let
    tomlFormat = pkgs.formats.toml {};
    json = wlib.types.structuredValueWith {typeName = "JSON";};

    textOrPath = lib.types.either lib.types.lines lib.types.path;

    readText = value:
      if lib.isPath value
      then builtins.readFile value
      else value;

    settings =
      if config.settings == null
      then {}
      else config.settings;

    ruleFiles =
      lib.mapAttrs' (
        name: value:
          lib.nameValuePair "rule-${name}" {
            content = readText value;
            relPath = "share/codex-wrapper/rules/${name}.rules";
          }
      )
      config.rules;

    skillFiles =
      if builtins.isAttrs config.skills
      then
        lib.mapAttrs' (
          name: value: let
            isDir = lib.isPath value && lib.pathIsDirectory value;
          in
            if isDir
            then
              lib.nameValuePair "skill-${name}" {
                content = toString value;
                relPath = "share/codex-wrapper/skills/${name}";
                builder = ''
                  source="$(cat "$1")"
                  cp -R "$source" "$2"
                '';
              }
            else
              lib.nameValuePair "skill-${name}" {
                content = readText value;
                relPath = "share/codex-wrapper/skills/${name}/SKILL.md";
              }
        )
        config.skills
      else {};

    configIdentity = builtins.substring 0 16 (builtins.hashString "sha256" (builtins.toJSON {
      inherit settings;
      profiles = config.profiles;
      context = toString config.context;
      contextOverride =
        if config.contextOverride == null
        then null
        else toString config.contextOverride;
      hooks = config.hooks;
      rules = lib.mapAttrs (_: v: toString v) config.rules;
      skills =
        if builtins.isAttrs config.skills
        then lib.mapAttrs (_: v: toString v) config.skills
        else toString config.skills;
    }));

    stateDirExpr =
      if config.stateDirectory != null
      then lib.escapeShellArg config.stateDirectory
      else ''"''${XDG_STATE_HOME:-$HOME/.local/state}/codex"'';

    installConstructed = attr: dest: ''
      mkdir -p "$(dirname "$CODEX_HOME/${dest}")"
      rm -rf "$CODEX_HOME/${dest}"
      cp -R ${lib.escapeShellArg config.constructFiles.${attr}.path} "$CODEX_HOME/${dest}"
    '';

    installFile = source: dest: ''
      mkdir -p "$(dirname "$CODEX_HOME/${dest}")"
      rm -rf "$CODEX_HOME/${dest}"
      cp -R ${lib.escapeShellArg (toString source)} "$CODEX_HOME/${dest}"
    '';

    configFile = tomlFormat.generate "codex-config.toml" settings;

    profileInstallSnippets =
      lib.mapAttrsToList
      (name: value: installFile (tomlFormat.generate "codex-profile-${name}.toml" value) "${name}.config.toml")
      config.profiles;
  in {
    imports = [wlib.modules.default];

    options = {
      settings = lib.mkOption {
        type = lib.types.nullOr tomlFormat.type;
        default = {};
        description = ''
          Codex configuration written to CODEX_HOME/config.toml.
          Mirrors Home Manager's programs.codex.settings.
        '';
      };

      profiles = lib.mkOption {
        type = lib.types.attrsOf tomlFormat.type;
        default = {};
        description = ''
          Named Codex profiles materialized as CODEX_HOME/<name>.config.toml.
        '';
      };

      context = lib.mkOption {
        type = textOrPath;
        default = "";
        description = ''
          Global Codex instructions written to CODEX_HOME/AGENTS.md.
        '';
      };

      contextOverride = lib.mkOption {
        type = lib.types.nullOr textOrPath;
        default = null;
        description = ''
          Global override instructions written to CODEX_HOME/AGENTS.override.md.
        '';
      };

      hooks = lib.mkOption {
        type = json;
        default = {};
        description = ''
          Codex lifecycle hooks written to CODEX_HOME/hooks.json.
        '';
      };

      skills = lib.mkOption {
        type =
          lib.types.either
          (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path))
          lib.types.path;
        default = {};
        description = ''
          Codex skills. Attribute-set values may be inline SKILL.md content,
          a SKILL.md file, or a complete skill directory. A directory value for
          the whole option is copied recursively into CODEX_HOME/skills.
        '';
      };

      rules = lib.mkOption {
        type = lib.types.attrsOf textOrPath;
        default = {};
        description = ''
          Codex rule files written to CODEX_HOME/rules/<name>.rules.
        '';
      };

      stateDirectory = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "$HOME/.local/state/codex-work";
        description = ''
          Writable CODEX_HOME used by the wrapper. If null, a wrapper-specific
          directory under XDG_STATE_HOME (or ~/.local/state) is used.
          A leading $HOME or ~/ is expanded by the wrapper at runtime.

          Authentication/session state remains writable here, while declarative
          files are refreshed from the wrapper on every invocation.
        '';
      };
    };

    config = {
      package = lib.mkDefault pkgs.codex;

      constructFiles =
        {
          context = {
            content = readText config.context;
            relPath = "share/codex-wrapper/AGENTS.md";
          };

          hooks = {
            content = builtins.toJSON {inherit (config) hooks;};
            relPath = "share/codex-wrapper/hooks.json";
          };
        }
        // lib.optionalAttrs (config.contextOverride != null) {
          contextOverride = {
            content = readText config.contextOverride;
            relPath = "share/codex-wrapper/AGENTS.override.md";
          };
        }
        // ruleFiles
        // skillFiles;

      runShell = [
        {
          name = "CODEX_WRAPPER_HOME";
          data = ''
            export CODEX_HOME=${stateDirExpr}
            mkdir -p "$CODEX_HOME"

            # Declarative configuration is refreshed on each invocation, while
            # auth/session/cache data in CODEX_HOME remains writable and persistent.
            ${installFile configFile "config.toml"}

            ${lib.optionalString (config.context != "") (installConstructed "context" "AGENTS.md")}
            ${lib.optionalString (config.contextOverride != null) (installConstructed "contextOverride" "AGENTS.override.md")}
            ${lib.optionalString (config.hooks != {}) (installConstructed "hooks" "hooks.json")}

            ${lib.concatStringsSep "\n" profileInstallSnippets}

            ${lib.concatStringsSep "\n" (lib.mapAttrsToList
              (name: _: installConstructed "rule-${name}" "rules/${name}.rules")
              config.rules)}

            ${
              if lib.isPath config.skills
              then ''
                rm -rf "$CODEX_HOME/skills"
                mkdir -p "$CODEX_HOME/skills"
                cp -R ${lib.escapeShellArg (toString config.skills)}/. "$CODEX_HOME/skills/"
              ''
              else
                lib.concatStringsSep "\n" (lib.mapAttrsToList
                  (
                    name: value: let
                      isDir = lib.isPath value && lib.pathIsDirectory value;
                    in
                      if isDir
                      then installConstructed "skill-${name}" "skills/${name}"
                      else installConstructed "skill-${name}" "skills/${name}/SKILL.md"
                  )
                  config.skills)
            }
          '';
        }
      ];

      meta.description = "OpenAI Codex CLI wrapper with declarative configuration";
    };
  };
}
