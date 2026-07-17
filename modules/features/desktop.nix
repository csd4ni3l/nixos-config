{self, ...}: {
  flake.nixosModules.desktop = {
    pkgs, config, ...
  }: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdg.portal.enable = true;
    xdg.portal.config.common.default = "*";

    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = ["amdgpu"];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session";
        };
      };
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      inter
      liberation_ttf
    ];

    environment.systemPackages = with pkgs; [
      nautilus
      nautilus-open-any-terminal
      gvfs
      file-roller
      mpv
      ffmpeg
      loupe # image viewer
      slurp # region select screenshot
      grim # screenshot
      pavucontrol
      gnome-calculator
    ];

    services.archive-manager.enable = true;

    programs.niri.enable = true;

    time.timeZone = "Europe/Budapest";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "hu_HU.UTF-8";
      LC_IDENTIFICATION = "hu_HU.UTF-8";
      LC_MEASUREMENT = "hu_HU.UTF-8";
      LC_MONETARY = "hu_HU.UTF-8";
      LC_NAME = "hu_HU.UTF-8";
      LC_NUMERIC = "hu_HU.UTF-8";
      LC_PAPER = "hu_HU.UTF-8";
      LC_TELEPHONE = "hu_HU.UTF-8";
      LC_TIME = "hu_HU.UTF-8";
    };

    services.upower.enable = true;

    security.polkit.enable = true;

    hardware = {
      enableAllFirmware = true;
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
      graphics = {
        enable = true;
        driSupport32Bit = true;
      };
    };

  };
}
