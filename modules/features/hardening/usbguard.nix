{self, ...}: {
  flake.nixosModules.HardeningUSBGuard = {...}: {
    services.usbguard = {
      enable = true;

      implicitPolicyTarget = "block";
      insertedDevicePolicy = "apply-policy";
      presentDevicePolicy = "apply-policy";
      presentControllerPolicy = "keep";

      IPCAllowedUsers = ["root" "csd4ni3l"];
      IPCAllowedGroups = ["wheel"];
      dbus.enable = true;
    };
  };
}
