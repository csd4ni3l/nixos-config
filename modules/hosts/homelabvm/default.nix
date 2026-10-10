{
  self,
  inputs,
  ...
}: let
  hostname = "homelabvm";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
      {system.stateVersion = "26.11"; system.name = hostname;}
      self.nixosModules.HomeLabVMConfiguration
    ];
  };
}
