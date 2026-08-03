{
  pkgs,
  inputs,
}:
inputs.nixpak.lib.nixpak {
  inherit (pkgs) lib;
  inherit pkgs;
}
