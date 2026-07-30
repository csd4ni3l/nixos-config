{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.framework16 = inputs.nixpkgs.lib.nixosSystem {
    system.stateVersion = "26.11";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.framework16Configuration
    ];
  };
}
