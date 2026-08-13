{self, ...}: {
  flake.nixosModules.HardeningBluetooth = {
    pkgs,
    inputs,
    ...
  }: {
    systemd.services = {
      bluetooth.serviceConfig = {
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;

        PrivateBPF = true;
        PrivateDevices = false;
        DevicePolicy = "closed";
        DeviceAllow = ["/dev/rfkill rw" "/dev/uinput rw"];
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;

        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = lib.mkForce true;
        ProtectKernelTunables = lib.mkForce true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectSystem = "strict";
        ReadWritePaths = ["-/var/lib/bluetooth" "-/run/systemd/unit-root"];

        RestrictAddressFamilies = ["AF_BLUETOOTH" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@resources" "~@privileged"];
      };
    };
  };
}
