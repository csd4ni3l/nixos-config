{...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        extra-substituters = [
          "https://attic.xuyh0120.win/lantian"
        ];
        extra-trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
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

    environment.systemPackages = with pkgs; [git]; # git is needed for basic operations
  };
}
