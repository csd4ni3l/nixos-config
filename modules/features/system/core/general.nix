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
      # CVE-2026-111943
      "Comodo AAA Services root"
      # https://hg-edge.mozilla.org/projects/nss/rev/26d38a0c3fb81e7fb2acedbaf4c42dd21dce0517
      "emSign ECC Root CA - G3"
      # https://hg-edge.mozilla.org/projects/nss/rev/8159223c48ceeb1273a1915bca95a517294ab0e0
      "emSign Root CA - C1"
      "emSign ECC Root CA - C3"
    ];

    time.timeZone = "Europe/Budapest";
    i18n.defaultLocale = "en_GB.UTF-8";

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [git]; # git is needed for basic operations
  };
}
