{self, ...}: {
  flake.nixosModules.HardeningUSBGuard = {
    pkgs,
    inputs,
    ...
  }: {
    systemd.services = {
      usbguard.serviceConfig = {
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
        SystemCallArchitectures = "native";
      };
    };

    "usbguard-dbus".serviceConfig = {
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectHome = true;
      MemoryDenyWriteExecute = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictRealtime = true;
      UMask = "0077";
      RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
      SystemCallArchitectures = "native";
      NoNewPrivileges = true;
    };
  };
}
