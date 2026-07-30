{self, ...}: {
  flake.nixosModules.desktop = {
    pkgs,
    inputs,
    lib,
    ...
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
      ffmpeg
      loupe # image viewer
      slurp # region select screenshot
      grim # screenshot
      pavucontrol
      gnome-calculator
      xwayland-satellite
      glib
      libmtp
      usbutils
      lshw
      pciutils
      wl-mirror
      openvpn
    ];

    programs.niri.enable = true;

    security.polkit.enable = true;

    systemd.user.services.niri.enableDefaultPath = false;

    services = {
      logind.settings = {
        Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
        };
      };
      gnome.gnome-keyring.enable = true;
      upower.enable = true;
      gvfs.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          extraConfig."10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-hw-volume" = false;
            };
          };
        };
      };
      udisks2 = {
        enable = true;
        settings = {
          "udisks2.conf" = {
            defaults = {
              automount = true;
              automount-on-insert = true;
            };
          };
        };
      };
      fwupd.enable = true;
    };

    security.rtkit.enable = true;

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
