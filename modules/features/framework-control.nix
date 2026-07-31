{...}: {
  flake.nixosModules.FrameworkControl = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      framework-control
      framework-tool
    ];

    systemd.services.framework-control = {
      description = "Framework Control Service";

      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      path = with pkgs; [
        framework-tool
        coreutils
        bash
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.framework-control}/bin/framework-control";
        Restart = "on-failure";
        RestartSec = 5;

        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
      };
    };
  };
}
