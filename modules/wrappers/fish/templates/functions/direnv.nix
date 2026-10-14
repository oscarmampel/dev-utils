{...}: {
  config.flake.wrapperTemplates.fish.functions.direnv = _: {
    __direnv_prompt_envrc = {
      source = true;
      onEvent = "fish_prompt";
      body = ''
        if not set -q DIRENV_DIR
          set -e __direnv_prompt_envrc_path
          return
        end

        set --local direnv_root (string replace --regex "^-" "" -- "$DIRENV_DIR")

        if test "$PWD" != "$direnv_root"; and not string match --quiet -- "$direnv_root/*" "$PWD"
          set -e __direnv_prompt_envrc_path
          return
        end

        set --local prompt_envrc (path basename -- "$direnv_root")
        set --local relative_dir (string replace --regex "^"(string escape --style=regex "$direnv_root")"/?" "" -- "$PWD")
        while test -n "$relative_dir"
          set prompt_envrc "../$prompt_envrc"
          set relative_dir (string replace --regex "^[^/]+/?" "" -- "$relative_dir")
        end

        set --global __direnv_prompt_envrc_path "$prompt_envrc"
      '';
    };
  };
}
