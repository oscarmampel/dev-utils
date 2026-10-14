{self, ...}: {
  flake.wrappers.direnv = {
    imports = [self.baseWrappers.direnv];

    env = {
      DIRENV_LOG_FORMAT = "";
    };

    settings = {
      global = {
        hide_env_diff = true;
      };
    };

    lib =
      (self.wrapperTemplates.direnv.lib.nix {})
      // (self.wrapperTemplates.direnv.lib.ruby {});
  };
}
