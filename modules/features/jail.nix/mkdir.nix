{
  flake.nixosModules.JailDirs = {
    pkgs,
    lib,
    config,
    ...
  }: let
    dirs =
      lib.sort (a: b: a < b)
      (
        [
          "Documents"
          "Downloads"
          "Music"
          "Projects"
          "Videos"
        ]
        ++ config.nixcfgs.jail_dirs
      );
    cmd = "${pkgs.bash}/bin/bash -c 'mkdir -p \"$HOME/${lib.concatStringsSep "\" \"$HOME/" dirs}\"'";
  in {
    systemd.user.services.jail-mkdir = {
      description = "Create persistent directories for jailed applications";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = cmd;
      };
    };
  };
}
