{self, ...}: {
  flake.nixosModules.HardeningPlymouth = {
    pkgs,
    inputs,
    ...
  }: {
    systemd.services = {
      plymouth-start.serviceConfig = {
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

      plymouth-quit.serviceConfig = {
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

      plymouth-quit-wait.serviceConfig = {
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

      plymouth-halt.serviceConfig = {
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

      plymouth-kexec.serviceConfig = {
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

      plymouth-poweroff.serviceConfig = {
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

      plymouth-reboot.serviceConfig = {
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

      plymouth-read-write.serviceConfig = {
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
