{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.framework16 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
      {system.stateVersion = "26.11";}
      self.nixosModules.framework16Configuration
    ];
  };
}
