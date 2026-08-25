{self, ...}: {
  flake.nixosModules.Ghidra = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
    # NOTE: Ghidra runs in the background instead of the foreground by default,
    # which means it gets killed after the wrapper script exits. Patch
    # ghidraRun to use fg mode so the JVM keeps the sandbox alive.
    ghidraFg = pkgs.runCommand "ghidra-fg" {meta.mainProgram = "ghidra";} ''
      mkdir -p "$out/lib/ghidra" "$out/bin"
      for entry in "${pkgs.ghidra}/lib/ghidra"/*; do
        name="$(basename "$entry")"
        [ "$name" != "ghidraRun" ] && ln -s "$entry" "$out/lib/ghidra/$name"
      done
      cp "${pkgs.ghidra}/lib/ghidra/ghidraRun" "$out/lib/ghidra/ghidraRun"
      chmod +w "$out/lib/ghidra/ghidraRun"
      substituteInPlace "$out/lib/ghidra/ghidraRun" \
        --replace-fail "launch.sh bg jdk Ghidra" "launch.sh fg jdk Ghidra"
      ln -s ../lib/ghidra/ghidraRun "$out/bin/ghidra"
      ln -s "${pkgs.ghidra}/share" "$out/share"
    '';
  in {
    environment.systemPackages = [
      (jail.mkSandboxed ghidraFg "ghidra" (with jail.combinators; [
        default
        unsafe-x11
        # NOTE: Fix Ghidra opening 2 blank (white) windows under non-reparenting WMs (niri/sway/hyprland).
        (set-env "_JAVA_AWT_WM_NONREPARENTING" "1")
        (rw-bind (noescape "~/Projects/Programming") (noescape "~/Projects/Programming"))
      ]))
    ];
  };
}
