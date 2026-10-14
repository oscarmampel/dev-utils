{lib, ...}: {
  config.systems = ["x86_64-linux" "aarch64-linux"];

  options.flake = {
    baseWrappers = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Configurable base wrapper modules.";
    };
    wrapperTemplates = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.raw;
      };
      default = {};
      description = "Reusable wrapper configuration fragments.";
    };
  };
}
