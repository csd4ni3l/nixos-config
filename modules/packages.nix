{...}: {
  systems = ["x86_64-linux"];
  perSystem = {pkgs, ...}: {
    packages.dmemcg-booster = pkgs.callPackage ../pkgs/dmemcg-booster {};
    packages.pelican-wings = pkgs.callPackage ../pkgs/wings {};
    packages.fluxer-canary = pkgs.callPackage ../pkgs/fluxer-canary {};

    # ArtCraft App Suite, (checking if this works out, if not, then i will remove it)
    packages.craft-wordcraft = pkgs.callPackage ../pkgs/craft/wordcraft.nix {};
    packages.craft-deckcraft = pkgs.callPackage ../pkgs/craft/deckcraft.nix {};
    packages.craft-gridcraft = pkgs.callPackage ../pkgs/craft/gridcraft.nix {};
    packages.craft-pdfcraft = pkgs.callPackage ../pkgs/craft/pdfcraft.nix {};
    packages.craft-vectorcraft = pkgs.callPackage ../pkgs/craft/vectorcraft.nix {};
  };
}
