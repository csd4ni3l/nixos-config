{
  pkgs,
  lib,
  ...
}: {
  services = {
    # mDNS/DNS-SD
    avahi.enable = false;

    # Geoclue (location services)
    geoclue2.enable = false;

    # NOTE: I need udisks2 for mounting MTP & SMB. I have other hardening methods as well as USBGuard so this should be safe.
    udisks2.enable = true;

    # NOTE: can safely disable, as if needed, will be started automatically
    accounts-daemon.enable = false;
  };

  # Harden Systemd services more than upstream, but do not use mkforce to keep compatibility
  # TODO: harden NetworkManager & ncsd without breaking anything. Last time it bricked DNS. (of course it was DNS)
  # TODO: harden udisks2 which made /run/media root:root and 700, but didn't mount anything
  systemd.services = {
    bluetooth.serviceConfig = {
      ProtectKernelLogs = true;
      ProtectHostname = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";
      ProtectHome = true;
      LockPersonality = true;
      RestrictRealtime = true;
      UMask = "0077";
      RestrictAddressFamilies = ["AF_UNIX" "AF_BLUETOOTH"];
      SystemCallFilter = [
        "~@obsolete"
        "~@cpu-emulation"
        "~@swap"
        "~@reboot"
        "~@mount"
      ];
      SystemCallArchitectures = "native";
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

    speech-dispatcher.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
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
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
      SystemCallArchitectures = "native";
    };

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
}
