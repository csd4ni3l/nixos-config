{...}: {
  systems = ["x86_64-linux"];
  perSystem = {pkgs, ...}: {
    packages.dmemcg-booster = pkgs.callPackage ../pkgs/dmemcg-booster {};
    packages.pelican-wings = pkgs.callPackage ../pkgs/wings {};
    packages.fluxer-canary = pkgs.callPackage ../pkgs/fluxer-canary {};
  };
}
