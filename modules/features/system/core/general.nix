{...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 2d";
      };

      optimise.automatic = true;
    };

    security.polkit.enable = true;

    # NOTE: Block Emudhra compromised CAs, applied to all hosts.
    security.pki.caCertificateBlacklist = [
      "Comodo AAA Services root"
      "emSign ECC Root CA - G3"
    ];

    time.timeZone = "Europe/Budapest";
    i18n.defaultLocale = "en_GB.UTF-8";

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [git]; # git is needed for basic operations
  };
}
