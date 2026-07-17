{self, ...}: {
  flake.nixosModules.desktop = {
    pkgs, config, ...
  }: {
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
      xwayland-satellite
    ];

    programs.niri.enable = true;

    security.polkit.enable = true;

    systemd.user.services.niri.enableDefaultPath = false;
    services.gnome.gnome-keyring.enable = true;
    services.archive-manager.enable = true;
    services.upower.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

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
