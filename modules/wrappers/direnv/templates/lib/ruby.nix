{...}: {
  config.flake.wrapperTemplates.direnv.lib.ruby = {
    nixpkgsUrl ? "github:NixOS/nixpkgs/nixpkgs-unstable",
    nixpkgsRubyUrl ? "github:bobvanderlinden/nixpkgs-ruby",
  }: {
    ruby-env = ''
      __use_ruby_env_nix_string() {
        local value=''${1//\\/\\\\}
        value=''${value//\"/\\\"}
        printf '"%s"' "$value"
      }

      __use_ruby_env_nix_string_list() {
        local item

        printf '['
        for item in "$@"; do
          printf ' '
          __use_ruby_env_nix_string "$item"
        done
        printf ' ]'
      }

      __use_ruby_env_write_if_changed() {
        local target=$1
        local tmp=$2

        if [ -f "$target" ] && cmp -s "$tmp" "$target"; then
          rm -f "$tmp"
        else
          mv "$tmp" "$target"
        fi
      }

      use_ruby_env() {
        if ! declare -F use_flake >/dev/null; then
          log_error "use_ruby_env requires nix-direnv's use flake support"
          return 1
        fi

        if [ ! -f .ruby-version ]; then
          log_error "use_ruby_env requires a .ruby-version file"
          return 1
        fi

        watch_file .ruby-version
        [ ! -f Gemfile ] || watch_file Gemfile
        [ ! -f Gemfile.lock ] || watch_file Gemfile.lock

        local ruby_version
        ruby_version=$(tr -d '[:space:]' < .ruby-version)
        if [ -z "$ruby_version" ]; then
          log_error ".ruby-version is empty"
          return 1
        fi

        local ruby_attr
        case "$ruby_version" in
          ruby-*) ruby_attr=$ruby_version ;;
          *) ruby_attr="ruby-$ruby_version" ;;
        esac

        if [[ ! "$ruby_attr" =~ ^ruby-[0-9]+(\.[0-9]+){1,2}([._+-][A-Za-z0-9._+-]+)?$ ]]; then
          log_error "unsupported Ruby version in .ruby-version: $ruby_version"
          return 1
        fi

        local system_packages arg
        system_packages=()

        while [ "$#" -gt 0 ]; do
          arg=$1
          shift

          case "$arg" in
            --package)
              if [ "$#" -eq 0 ]; then
                log_error "use_ruby_env --package requires a nixpkgs package path"
                return 1
              fi

              system_packages+=("$1")
              shift
              ;;
            --package=*)
              system_packages+=("''${arg#--package=}")
              ;;
            --)
              system_packages+=("$@")
              break
              ;;
            -*)
              log_error "unknown use_ruby_env option: $arg"
              return 1
              ;;
            *)
              system_packages+=("$arg")
              ;;
          esac
        done

        local system_package
        for system_package in "''${system_packages[@]}"; do
          if [[ ! "$system_package" =~ ^[A-Za-z_][A-Za-z0-9_+-]*(\.[A-Za-z_][A-Za-z0-9_+-]*)*$ ]]; then
            log_error "invalid nixpkgs package path for use_ruby_env: $system_package"
            return 1
          fi
        done

        local layout_dir flake_dir flake_file tmp_file nix_system_packages
        layout_dir=$(direnv_layout_dir)
        flake_dir="$layout_dir/ruby-env-flake"
        flake_file="$flake_dir/flake.nix"
        tmp_file="$flake_file.$$.tmp"
        nix_system_packages=$(__use_ruby_env_nix_string_list "''${system_packages[@]}")

        mkdir -p "$flake_dir"

        cat > "$tmp_file" <<EOF
      {
        description = "Generated Ruby environment for direnv";

        inputs = {
          nixpkgs.url = "${nixpkgsUrl}";
          nixpkgs-ruby = {
            url = "${nixpkgsRubyUrl}";
            inputs.nixpkgs.follows = "nixpkgs";
          };
        };

        outputs = {
          nixpkgs,
          nixpkgs-ruby,
          ...
        }: let
          systems = [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
          ];
          forAllSystems = nixpkgs.lib.genAttrs systems;
        in {
          devShells = forAllSystems (
            system: let
              pkgs = import nixpkgs {inherit system;};
              ruby = nixpkgs-ruby.packages.\''${system}."$ruby_attr";
              systemPackageNames = $nix_system_packages;
              systemPackages =
                map (
                  name:
                    nixpkgs.lib.attrByPath
                    (nixpkgs.lib.splitString "." name)
                    (throw "use_ruby_env: pkgs.\''${name} was not found")
                    pkgs
                )
                systemPackageNames;
            in {
              default = pkgs.mkShell {
                packages = [ruby pkgs.pkg-config] ++ systemPackages;
                LD_LIBRARY_PATH = nixpkgs.lib.makeLibraryPath systemPackages;
                RUBY_VERSION = "$ruby_attr";
              };
            }
          );
        };
      }
      EOF

        __use_ruby_env_write_if_changed "$flake_file" "$tmp_file"

        use_flake "path:$flake_dir"

        export BUNDLE_PATH="$layout_dir/bundle/$ruby_attr"
        export BUNDLE_APP_CONFIG="$layout_dir/bundle-config/$ruby_attr"
        unset GEM_HOME GEM_PATH GEM_SPEC_CACHE
      }
    '';
  };
}
