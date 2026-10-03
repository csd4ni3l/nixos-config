{self, ...}: {
  flake.nixosModules.Slick = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
    slackNoDesktop = pkgs.slack.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -f $out/share/applications/slack.desktop 2>/dev/null || true
        rm -f $out/share/applications/*.desktop 2>/dev/null || true
      '';
    });
  in {
    environment.systemPackages = [
      slackNoDesktop
      (jail.mkSandboxed inputs.slick.packages.${pkgs.system}.default "slick" (with jail.combinators; [
        default
        network
        (rw-bind (noescape "~/.config/slick") (noescape "~/.config/slick"))
        (rw-bind (noescape "~/.local/share/slick") (noescape "~/.local/share/slick"))
        (rw-bind (noescape "~/.cache/slick") (noescape "~/.cache/slick"))
        (try-rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
      ]))
    ];
  };
}
