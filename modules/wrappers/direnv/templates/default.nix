{lib, ...}: {
  options.flake.wrapperTemplates.direnv.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.functionTo lib.types.attrs);
    default = {};
    description = ''
      Reusable templates for direnv lib/*.sh wrapper configuration.
    '';
  };
}
