{self, ...}: {
  flake.nixosModules.NicotinePlus = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed
        (pkgs.nicotine-plus.overrideAttrs (old: {
          meta = (old.meta or {}) // {mainProgram = "nicotine";};
        }))
        "nicotine"
        (with jail.combinators; [
          default
          network

          (rw-bind (noescape "~/Music") (noescape "~/Music"))
        ]))
    ];
  };
}
