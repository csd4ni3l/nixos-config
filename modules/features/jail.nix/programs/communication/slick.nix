{self, ...}: {
  flake.nixosModules.Slick = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
    slackNoDesktop = pkgs.slack.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          rm -f $out/share/applications/slack.desktop 2>/dev/null || true
          rm -f $out/share/applications/*.desktop 2>/dev/null || true
        '';
    });

    # NOTE: work around slick's stale pins: match Slack's Electron 43 and patch
    # the nodeModulesHash until upstream fixes them.
    slickSrc = pkgs.runCommand "slick-src" {} ''
      cp -r ${inputs.slick.outPath} $out
      chmod -R u+w $out
      substituteInPlace $out/packaging/nix/pins.json \
        --replace 'sha256-DRFQRlER9UQe+ZOzltlA0OazsXMSZx2KdLpjDtCSfpw=' \
                  'sha256-3AzqXo9hSI7RKY0BU/CFbJnHIvU/EJiUN+X0Ad1pB8M='
    '';

    slick = (inputs.slick.packages.${pkgs.system}.default).override {
      src = slickSrc;
      electron = pkgs.electron_43;
    };
  in {
    nixcfgs.jail_dirs = [".cache/slick" ".config/slick"];

    environment.systemPackages = [
      slackNoDesktop
      (jail.mkSandboxed slick "slick" (with jail.combinators; [
        keyring-access
        default
        network
        (rw-bind (noescape "~/.config/slick") (noescape "~/.config/slick"))
        (rw-bind (noescape "~/.cache/slick") (noescape "~/.cache/slick"))
        (try-rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
      ]))
    ];
  };
}
