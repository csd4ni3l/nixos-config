{self, ...}: {
  flake.nixosModules.desktop = {
    pkgs, inputs, lib, ...
  }: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdg.portal.enable = true;
    xdg.portal.config.common.default = "*";

    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = ["amdgpu"];

    programs.noctalia-greeter = {
      enable = true;

      greeter-args = "";
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard = {
          layout = "hu";
        };
      };
    };


    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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
        enable32Bit = true;
      };
    };
  };
}
