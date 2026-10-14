{...}: {
  config.flake.wrapperTemplates.fish.functions.nix = _: {
    nix-shell = {
      source = true;
      wraps = "nix-shell";
      description = "Run nix-shell and expose requested packages to the prompt";
      body = ''
        set --local packages
        set --local collect_packages false

        for arg in $argv
          switch $arg
            case -p --packages
              set collect_packages true
            case '-*' '--*'
              set collect_packages false
            case '*'
              if test "$collect_packages" = true
                set --append packages (string replace --regex '^nixpkgs#' "" -- "$arg")
              end
          end
        end

        set -l packages $packages $NIX_SHELL_ENV_PACKAGES
        set -l nix_shell (command -v nix-shell)
        NIX_SHELL_ENV_PACKAGES=$packages $nix_shell $argv
      '';
    };
  };
}
