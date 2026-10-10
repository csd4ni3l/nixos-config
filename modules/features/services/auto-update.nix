{...}: {
  flake.nixosModules.auto-update = {
    config,
    pkgs,
    ...
  }: let
    hostname = config.system.name;
    updateScript = pkgs.writeShellScript "nixos-config-update" ''
      set -eu
      export GIT_TERMINAL_PROMPT=0

      exec 9>/run/nixos-config-update.lock
      ${pkgs.util-linux}/bin/flock -n 9 || exit 0

      repo=/persist/nixos-config

      if [[ ! -e $repo/.git ]]; then
        ${pkgs.git}/bin/git clone https://git.csd4ni3l.hu/csd4ni3l/nixos-config.git "$repo"
      fi

      old=$(${pkgs.git}/bin/git -C "$repo" rev-parse HEAD)
      ${pkgs.git}/bin/git -C "$repo" pull --ff-only
      new=$(${pkgs.git}/bin/git -C "$repo" rev-parse HEAD)

      if [[ "$old" == "$new" ]]; then
        echo "nixos-config: no changes"
        exit 0
      fi

      exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
        --flake "$repo#${hostname}" \
        --no-reexec \
        --accept-flake-config
    '';
  in {
    systemd.services.nixos-config-update = {
      description = "Pull nixos-config and rebuild the system";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${updateScript}";
      };
    };

    systemd.timers.nixos-config-update = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };
}
