{self, ...}: {
  flake.nixosModules.OpenCode = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.opencode "opencode" (with jail.combinators; [
        common-access
        network
        mount-cwd
        (rw-bind (noescape "~/.config/opencode") (noescape "~/.config/opencode"))
        (rw-bind (noescape "~/.local/share/opencode") (noescape "~/.local/share/opencode"))
        (rw-bind (noescape "~/.local/state/opencode") (noescape "~/.local/state/opencode"))
      ]))
    ];
  };
}
