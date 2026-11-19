{...}: {
  flake.nixosModules.podman = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [docker-compose passt];
    virtualisation = {
      podman = {
        enable = true;
        extraPackages = [pkgs.passt];
        # NOTE: backport upstream #30243; crun 1.31 fails rootless exec when
        # the inherited oom_score_adj is higher than the container's.
        # TODO: remove once podman includes this fix.
        package = pkgs.podman.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              (pkgs.fetchpatch {
                name = "podman-exec-clamp-oom-score-adj.patch";
                url = "https://github.com/podman-container-tools/podman/commit/5816cc40c678dc1d2c00ba022c3614c3eb99e365.patch";
                hash = "sha256-JGBnkipsbHMdrVJveDDfpMY2fKZ8dDQQtzE9q0jd4v0=";
              })
            ];
        });
      };
      containers.containersConf.settings.network = {
        default_rootless_network_cmd = "pasta";
      };
    };
  };
}
