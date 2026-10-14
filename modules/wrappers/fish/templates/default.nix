{lib, ...}: {
  options.flake.wrapperTemplates.fish.functions = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.functionTo lib.types.attrs);
    default = {};
    description = ''
      Reusable templates for wrapper configuration.
    '';
  };
}
