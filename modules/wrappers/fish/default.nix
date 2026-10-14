{...}: {
  flake.baseWrappers.fish = {
    config,
    lib,
    wlib,
    pkgs,
    ...
  }: let
    inherit (lib) isAttrs mkOption optional types;

    cfg = config;

    functionModule = types.submodule {
      options = {
        body = mkOption {
          type = types.lines;
          description = "The function body.";
        };

        source = mkOption {
          type = types.bool;
          default = false;
          description = "Source this function during shell initialisation instead of relying only on autoload.";
        };

        argumentNames = mkOption {
          type = with types; nullOr (either str (listOf str));
          default = null;
          description = "Assigns successive command line arguments to the given names.";
        };

        description = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Description for completions.";
        };

        wraps = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Inherit completions from the wrapped command.";
        };

        onEvent = mkOption {
          type = with types; nullOr (either str (listOf str));
          default = null;
          description = "Run this function when the specified event is emitted.";
        };

        onVariable = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Run this function when the specified variable changes.";
        };

        onJobExit = mkOption {
          type = with types; nullOr (either str int);
          default = null;
          description = "Run this function when the specified job exits.";
        };

        onProcessExit = mkOption {
          type = with types; nullOr (either str int);
          default = null;
          description = "Run this function when the specified process exits.";
        };

        onSignal = mkOption {
          type = with types; nullOr (either str int);
          default = null;
          description = "Run this function when the specified signal is delivered.";
        };

        noScopeShadowing = mkOption {
          type = types.bool;
          default = false;
          description = "Allow the function to access variables from calling functions.";
        };

        inheritVariable = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Snapshot the value of the specified variable when the function is defined.";
        };
      };
    };

    mkModifier = name: value: optional (value != null) "--${name}=${lib.escapeShellArg (toString value)}";
    mkListModifiers = name: value:
      lib.optionals (value != null) (map (v: "--${name}=${lib.escapeShellArg (toString v)}") (lib.toList value));
    mkBoolModifier = name: value: optional value "--${name}";
    mkArgumentNames = value:
      optional (value != null) "--argument-names ${lib.concatMapStringsSep " " (v: lib.escapeShellArg (toString v)) (lib.toList value)}";

    mkFunction = name: def: let
      attrs = isAttrs def;
      body = lib.strings.removeSuffix "\n" (
        if attrs
        then def.body
        else def
      );
      modifiers =
        if attrs
        then
          mkModifier "description" def.description
          ++ mkModifier "wraps" def.wraps
          ++ mkListModifiers "on-event" def.onEvent
          ++ mkModifier "on-variable" def.onVariable
          ++ mkModifier "on-job-exit" def.onJobExit
          ++ mkModifier "on-process-exit" def.onProcessExit
          ++ mkModifier "on-signal" def.onSignal
          ++ mkBoolModifier "no-scope-shadowing" def.noScopeShadowing
          ++ mkModifier "inherit-variable" def.inheritVariable
          ++ mkArgumentNames def.argumentNames
        else [];
    in ''
      function ${name}${lib.optionalString (modifiers != []) " ${toString modifiers}"}
        ${body}
      end
    '';

    functionsDir = "${dirOf config.constructFiles.generatedConfig.path}/fish-functions";
    functionFiles =
      lib.mapAttrs' (
        name: def:
          lib.nameValuePair "fish-functions/${name}" {
            content = mkFunction name def;
            output = lib.mkOverride 0 config.constructFiles.generatedConfig.output;
            relPath = lib.mkOverride 0 "${dirOf config.constructFiles.generatedConfig.relPath}/fish-functions/${name}.fish";
          }
      )
      cfg.functions;
    sourcedFunctionFiles = lib.pipe cfg.functions [
      (lib.filterAttrs (_: def: isAttrs def && def.source))
      (lib.mapAttrsToList (name: _: "${functionsDir}/${name}.fish"))
    ];
  in {
    imports = [wlib.wrapperModules.fish];

    options = {
      functions = mkOption {
        type = with types; attrsOf (either lines functionModule);
        default = {};
        example = {
          gitignore = "curl -sL https://www.gitignore.io/api/$argv";
          __fish_command_not_found_handler = {
            body = "__fish_default_command_not_found_handler $argv[1]";
            onEvent = "fish_command_not_found";
          };
        };
        description = "Fish functions to define in the generated wrapper configuration.";
      };
    };
    config = {
      constructFiles = functionFiles;
      configFile.content = lib.mkIf (cfg.functions != {}) (lib.mkAfter ''
        set fish_function_path ${functionsDir} $fish_function_path
        ${lib.optionalString (sourcedFunctionFiles != []) ''
          for function_file in ${lib.concatMapStringsSep " " lib.escapeShellArg sourcedFunctionFiles}
            source $function_file
          end
          set -e function_file
        ''}
      '');
    };
  };
}
