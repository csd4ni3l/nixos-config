{self, ...}: {
  flake.nixosModules.HardeningMisc = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [kernel-hardening-checker lynis];

    fileSystems."/proc" = {
      device = "proc";
      fsType = "proc";
      options = ["hidepid=2" "gid=42"];
    };

    # TODO: figure out something cause this breaks browsers and stuff
    # environment.memoryAllocator.provider = "graphene-hardened-light";

    # Use & Force NTS (Network Time Security)
    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;

      extraConfig = ''
        server time.cloudflare.com iburst nts
        server ntppool1.time.nl iburst nts
        server nts.netnod.se iburst nts
        server ptbtime1.ptb.de iburst nts
        server time.dfm.dk iburst nts

        minsources 3
        authselectmode require

        makestep 1.0 3

        cmdport 0
      '';
    };
  };
}
