{self, ...}: {
  flake.nixosModules.Framework16USBGuard = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [usbguard-notifier];

    services.usbguard.ruleFile = "/run/secrets/usbguard-rules.conf";

    sops.secrets."usbguard-rules" = {
      path = "/run/secrets/usbguard-rules.conf";
      owner = "root";
      group = "root";
      mode = "0644";
      restartUnits = ["usbguard.service"];
    };
  };
}
