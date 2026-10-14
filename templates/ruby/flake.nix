{
  description = "Ruby development shell with MySQL";

  inputs = {
    dev-utils.url = "github:oscarmampel/dev-utils";
    container-devshell.url = "github:oscarmampel/devenv";
    container-devshell.inputs.nixpkgs.follows = "nixpkgs";
    container-devshell.inputs.flake-parts.follows = "flake-parts";
    nixpkgs.follows = "dev-utils/nixpkgs";
    flake-parts.follows = "dev-utils/flake-parts";

    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    container-devshell,
    dev-utils,
    flake-parts,
    nixpkgs-ruby,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [container-devshell.flakeModules.containerDevShell dev-utils.flakeModules.development];
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {pkgs, ...}: let
        rubyVersion = (nixpkgs-ruby.lib.readRubyVersionFile ./.ruby-version).version;
        ruby = nixpkgs-ruby.lib.mkRuby {inherit pkgs rubyVersion;};
      in {
        devshell.packages = [ruby];
        devshell.buildInputs = [pkgs.mariadb-connector-c];
        devshell.nativeBuildInputs = [pkgs.pkg-config];

        devshell.container = {
          environment.MYSQL_HOST = "mysql";
          depends_on.mysql.condition = "service_started";
          networks = ["default" "database"];
        };

        devshell.compose = {
          services.mysql = {
            image = "docker.io/library/mysql:8.4";
            environment = {
              MYSQL_ALLOW_EMPTY_PASSWORD = "yes";
              MYSQL_DATABASE = "development";
            };
            networks = ["database"];
            volumes = ["mysql-data:/var/lib/mysql"];
          };
          networks.default = {};
          networks.database.internal = true;
          volumes.mysql-data = {};
        };
      };
    };
}
