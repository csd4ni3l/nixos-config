{self, ...}: {
  flake.nixosModules.PdfCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/pdfcraft" ".local/share/pdfcraft"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-pdfcraft "pdfcraft"
        (with jail.combinators; [
          default
          (rw-bind (noescape "~/.config/pdfcraft") (noescape "~/.config/pdfcraft"))
          (rw-bind (noescape "~/.local/share/pdfcraft") (noescape "~/.local/share/pdfcraft"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
