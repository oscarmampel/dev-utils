{lib, ...}: {
  config.flake.wrapperTemplates.direnv.lib.nix = {fish ? "fish"}: let
    repo = builtins.fetchGit {
      url = "https://github.com/nix-community/nix-direnv.git";
      rev = "7a8340f7478661c9a28b9014d0575a171f49dbce";
    };
  in {
    nix = ''
      source ${repo}/direnvrc

      __nix_direnv_use_nix=$(declare -f use_nix)
      eval "''${__nix_direnv_use_nix/use_nix/__nix_direnv_original_use_nix}"

      use_nix() {
        local packages=()
        local collect_packages=false
        local package_env
        local arg

        for arg in "$@"; do
          if [ "$collect_packages" = true ]; then
            packages+=("''${arg#nixpkgs#}")
            continue
          fi

          case "$arg" in
            -p|--packages)
              collect_packages=true
              ;;
          esac
        done

        __nix_direnv_original_use_nix "$@"
        local status=$?

        if [ "$status" -eq 0 ] && [ "''${#packages[@]}" -gt 0 ]; then
          package_env=$(
            command ${lib.escapeShellArg fish} -c '
              set --local packages $DIRENV_NIX_SHELL_ENV_PACKAGES $argv
              string join " " -- $packages
            ' -- "''${packages[@]}"
          )
          export DIRENV_NIX_SHELL_ENV_PACKAGES="$package_env"
        fi

        return "$status"
      }
    '';
  };
}
