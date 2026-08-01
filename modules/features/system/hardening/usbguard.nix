{...}: {
  flake.nixosModules.HardeningUSBGuard = {config, ...}: {
    services.usbguard = {
      enable = true;

      implicitPolicyTarget = "block";
      insertedDevicePolicy = "apply-policy";
      presentDevicePolicy = "apply-policy";
      presentControllerPolicy = "keep";

      IPCAllowedUsers = ["root" "${config.nixcfgs.username}"];
      IPCAllowedGroups = ["wheel"];
      dbus.enable = true;
    };
  };
}
