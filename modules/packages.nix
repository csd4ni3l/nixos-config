{...}: {
  systems = ["x86_64-linux"];
  perSystem = {pkgs, ...}: {
    packages.dmemcg-booster = pkgs.callPackage ../pkgs/dmemcg-booster {};
  };
}
