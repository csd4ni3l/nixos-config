{self, inputs, ...}: {
  flake.nixosConfigurations.framework16 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.framework16Configuration
    ];
  };
}
