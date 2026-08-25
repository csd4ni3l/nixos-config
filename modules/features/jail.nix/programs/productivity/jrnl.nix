{self, ...}: {
  flake.nixosModules.Jrnl = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.jrnl "jrnl" (with jail.combinators; [
        (rw-bind (noescape "~/.local/share/jrnl") (noescape "~/.local/share/jrnl"))
        (rw-bind (noescape "~/.config/jrnl") (noescape "~/.config/jrnl"))
      ]))
    ];
  };
}
