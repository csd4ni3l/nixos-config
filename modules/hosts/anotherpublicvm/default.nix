{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.anotherpublicvm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
      {system.stateVersion = "26.11";}
      self.nixosModules.AnotherPublicVMConfiguration
    ];
  };
}
