{...}: {
  config.flake.wrapperTemplates.fish.functions.prompt = _: {
    prompt_virtual_env = {
      source = true;
      description = "Display Python or Nix virtual environment";
      body = ''
        set envs

        if test "$CONDA_DEFAULT_ENV"
          set envs $envs "conda[$CONDA_DEFAULT_ENV]"
        end

        if test "$VIRTUAL_ENV"
          set py_env (basename $VIRTUAL_ENV)
          set envs $envs "py[$py_env]"
        end

        set direnv_symbol \uF4D4
        if set -q __direnv_prompt_envrc_path
          set envs $envs "$direnv_symbol $__direnv_prompt_envrc_path"
        end

        if test "$RUBY_VERSION"
          set ruby_symbol \uE739
          set envs $envs "$ruby_symbol $RUBY_VERSION"
        end

        set nix_symbol \uF313
        set -l packages $NIX_SHELL_ENV_PACKAGES $DIRENV_NIX_SHELL_ENV_PACKAGES
        if test (count $packages) -gt 0
          set -l uniq_packages (string split " " -- $packages | sort | uniq)
          set -l packages_text (string join -- " " $uniq_packages)
          set envs $envs "$nix_symbol $packages_text"
        end

        if test "$envs"
          set -l virtual_env_colors $color_virtual_env_bg c0c0c0
          set -l env_index 1

          for env_part in $envs
            set -l color_index (math "($env_index - 1) % 2 + 1")
            prompt_segment $virtual_env_colors[$color_index] $color_virtual_env_str $env_part
            set env_index (math "$env_index + 1")
          end
        end
      '';
    };
  };
}
