{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.neovim =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;

        modules = [
          self.modules.nvim.nix
          self.modules.nvim.theme
          self.modules.nvim.ruby
          self.modules.nvim.go
          self.modules.nvim.python
          self.modules.nvim.rust
          self.modules.nvim.neotree
          self.modules.nvim.insights
          self.modules.nvim.git
          self.modules.nvim.base
        ];
      }).neovim;
  };
}
