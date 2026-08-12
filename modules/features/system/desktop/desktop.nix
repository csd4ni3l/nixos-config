{...}: {
  flake.nixosModules.desktop = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    nix.settings = {
      extra-substituters = [
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdg.portal.enable = true;
    xdg.portal.config.common.default = "*";

    boot.initrd.kernelModules = ["amdgpu"];

    # NOTE: disable unneeded speech-dispatcher
    services.speechd.enable = lib.mkForce false;

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
        # NOTE: I need udisks2 for mounting MTP & SMB. I have other hardening methods as well as USBGuard so this should be safe.
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
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
