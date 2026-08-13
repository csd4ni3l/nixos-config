{self, ...}: {
  flake.nixosModules.HardeningServices = {lib, ...}: {
    services = {
      # mDNS/DNS-SD
      avahi.enable = false;

      # Geoclue (location services)
      geoclue2.enable = false;

      # NOTE: can safely disable, as if needed, will be started automatically
      accounts-daemon.enable = false;
    };

    # Harden Systemd services more than upstream, but do not use mkforce to keep compatibility
    # TODO: harden udisks2 which made /run/media root:root and 700, but didn't mount anything
    systemd.services = {
      NetworkManager.serviceConfig = {
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;

        PrivateBPF = true;
        PrivateDevices = false;
        DevicePolicy = "closed";
        DeviceAllow = ["/dev/net/tun rw"];
        PrivateIPC = true;
        PrivateTmp = true;

        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectSystem = "strict";

        RestrictNamespaces = true;
        RestrictRealtime = true;

        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "@privileged"];
      };

      polkit.serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX"];
        SystemCallArchitectures = "native";
      };

      wpa_supplicant.serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectClock = true;
        LockPersonality = true;
        RestrictRealtime = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" "AF_PACKET"];
        SystemCallArchitectures = "native";
      };

      chronyd.serviceConfig = {
        ProtectSystem = "full";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        SystemCallArchitectures = "native";
      };

      fwupd.serviceConfig = {
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
        SystemCallArchitectures = "native";
      };

      dbus-broker.serviceConfig = {
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectHome = true;
        LockPersonality = true;
        RestrictRealtime = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX"];
        SystemCallArchitectures = "native";
      };

      power-profiles-daemon.serviceConfig = {
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectClock = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX"];
        SystemCallArchitectures = "native";
      };

      upower.serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectClock = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX"];
        SystemCallArchitectures = "native";
      };

      dconf.serviceConfig = {
        ProtectSystem = "strict";
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectClock = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        RestrictAddressFamilies = ["AF_UNIX"];
        SystemCallArchitectures = "native";
      };

      lactd.serviceConfig = {
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
      };

      systemd-rfkill.serviceConfig = {
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

      systemd-ask-password-console.serviceConfig = {
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

      systemd-ask-password-wall.serviceConfig = {
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
