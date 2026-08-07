{self, ...}: {
  flake.nixosModules.Ghidra = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.ghidra_sre.Ghidra";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
              x11 = true;
            };
            # NOTE: tmpfs on /tmp hides the X11 socket bind, so drop it
            tmpfs = lib.mkForce [];
            # NOTE: Fix Ghidra opening 2 blank (white) windows under non-reparenting WMs (niri/sway/hyprland).
            env = {
              _JAVA_AWT_WM_NONREPARENTING = "1";
            };
            bind.rw = [(sloth.concat' sloth.homeDir "/Projects/Programming")];
          };

          # NOTE: Ghidra runs in the background instead of the foreground by default,
          # which means it gets killed after the wrapper script exits. Patch
          # ghidraRun to use fg mode so the JVM keeps the sandbox alive.
          app.package = let
            ghidra = pkgs.ghidra;
          in pkgs.runCommand "ghidra-fg" { } ''
            mkdir -p "$out/lib/ghidra" "$out/bin"
            for entry in "${ghidra}/lib/ghidra"/*; do
              name="$(basename "$entry")"
              [ "$name" != "ghidraRun" ] && ln -s "$entry" "$out/lib/ghidra/$name"
            done
            cp "${ghidra}/lib/ghidra/ghidraRun" "$out/lib/ghidra/ghidraRun"
            chmod +w "$out/lib/ghidra/ghidraRun"
            substituteInPlace "$out/lib/ghidra/ghidraRun" \
              --replace-fail "launch.sh bg jdk Ghidra" "launch.sh fg jdk Ghidra"
            ln -s ../lib/ghidra/ghidraRun "$out/bin/ghidra"
            ln -s "${ghidra}/share" "$out/share"
          '';
          app.binPath = "bin/ghidra";
        };
      }).config.env
    ];
  };
}
