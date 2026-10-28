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

    time.timeZone = "Europe/Budapest";
    i18n.defaultLocale = "en_GB.UTF-8";

    programs.zsh.enable = true;

    # NOTE: sphinx-hook reads only the first element of the sphinxBuilders array
    # under structuredAttrs, so the man output of khal (pulled in by DMS) is empty.
    nixpkgs.overlays = [
      (final: prev: {
        khal = prev.khal.overrideAttrs (_: {
          sphinxBuilders = "html man";
        });
      })
    ];

    environment.systemPackages = with pkgs; [git]; # git is needed for basic operations
  };
}
