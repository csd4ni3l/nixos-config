{ pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home.username = "csd4ni3l";
  home.homeDirectory = "/home/csd4ni3l";
  home.stateVersion = "26.05";

  xdg.configFile."niri".source = ./cfg/niri;
  xdg.configFile."noctalia/config.toml".source = ./cfg/noctalia/config.toml;
  xdg.configFile."Mangohud/MangoHud.conf".source = ./cfg/mangohud/Mangohud.conf;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/usr/local/share"
    "/var/lib/flatpak/exports/share"
    "/home/csd4ni3l/.local/share/flatpak/exports/share"
  ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # File manager
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      # Text / source code
      "text/plain" = [ "dev.zed.Zed.desktop" ];
      "text/markdown" = [ "md.obsidian.Obsidian.desktop" ];
      "text/x-python" = [ "dev.zed.Zed.desktop" ];
      "text/x-rust" = [ "dev.zed.Zed.desktop" ];
      "application/json" = [ "dev.zed.Zed.desktop" ];
      "application/xml" = [ "dev.zed.Zed.desktop" ];

      # Images
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/avif" = [ "org.gnome.Loupe.desktop" ];

      # Video
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/mpeg" = [ "mpv.desktop" ];

      # Audio
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/x-wav" = [ "mpv.desktop" ];

      # Office documents
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/msword" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.ms-excel" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.ms-powerpoint" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];

      # Archives
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];

      # Browser
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {

      scrollback_lines = 10000;
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12.0;
      background_opacity = "0.4";
      enable_audio_bell = false;
      confirm_os_window_close = -1;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    initContent = ''
      eval "$(zoxide init zsh)"
    '';

    shellAliases = {
      cat = "bat";
      cd = "z";
      ls = "eza";
      top = "btop";
      lg = "lazygit";
      yz = "yazi";
      ll = "eza -la";
      gs = "git status";
      rebuild = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      directory.truncation_length = 3;
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
      };
      nix_shell = {
        symbol = " ";
        format = "[$symbol$state]($style) ";
      };
    };

  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "csd4ni3l";
        email = "csd4ni3l_contact.ladle014@passmail.com";
      };
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.noctalia = {
    enable = true;
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "high-quality";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };

  services.flatpak.overrides.files = [
    ./cfg/flatpak-overrides/org.prismlauncher.PrismLauncher
    ./cfg/flatpak-overrides/app.twintaillauncher.ttl
    ./cfg/flatpak-overrides/com.github.tchx84.Flatseal
    ./cfg/flatpak-overrides/com.logseq.Logseq
    ./cfg/flatpak-overrides/com.obsproject.Studio
    ./cfg/flatpak-overrides/com.orcaslicer.OrcaSlicer
    ./cfg/flatpak-overrides/io.missioncenter.MissionCenter
    ./cfg/flatpak-overrides/md.obsidian.Obsidian
    ./cfg/flatpak-overrides/net.mullvad.MullvadBrowser
    ./cfg/flatpak-overrides/org.fedoraproject.MediaWriter
    ./cfg/flatpak-overrides/org.getmonero.Monero
    ./cfg/flatpak-overrides/org.ghidra_sre.Ghidra
    ./cfg/flatpak-overrides/org.kde.kdenlive
    ./cfg/flatpak-overrides/org.nicotine_plus.Nicotine
    ./cfg/flatpak-overrides/org.onlyoffice.desktopeditors
  ];

  services = {
    flatpak = {
      enable = true;
      update.onActivation = true; # automatically update on reboot
      packages = [
        "org.prismlauncher.PrismLauncher"
        "app.twintaillauncher.ttl"
        "com.github.tchx84.Flatseal"
        "com.logseq.Logseq"
        "com.obsproject.Studio"
        "com.obsproject.Studio.Plugin.Gstreamer"
        "com.obsproject.Studio.Plugin.GStreamerVaapi"
        "com.orcaslicer.OrcaSlicer"
        "io.github.flattool.Ignition"
        "io.missioncenter.MissionCenter"
        "md.obsidian.Obsidian"
        "net.mullvad.MullvadBrowser"
        "org.fedoraproject.MediaWriter"
        "org.getmonero.Monero"
        "org.ghidra_sre.Ghidra"
        "org.kde.kdenlive"
        "org.nicotine_plus.Nicotine"
        "org.onlyoffice.desktopeditors"
        "org.torproject.torbrowser-launcher"
        "net.portswigger.BurpSuite-Community"
      ];
    };
  };

  home.packages = with pkgs; [
    # shell env
    yazi
    zoxide
    lazygit
    ripgrep
    fd
    fzf
    bat
    eza
    jq
    unzip
    htop
    btop
    flatpak
    nix-output-monitor

    # clipboard
    wl-clip-persist
    cliphist
    wl-clipboard

    # development
    rustup
    ccache
    mold
    clang
    uv
    zed-editor
    pipx
    opencode
    gdb
    pkg-config
    direnv
    nix-direnv
    nil
    nixd

    # hacking
    metasploit
    nmap
    hydra
    ffuf
    gobuster
    sqlmap
    john
    socat
    nikto
    hashcat
    tcpdump
    wireshark

    # OSINT tools
    maigret
    sherlock

    # networking
    netcat-openbsd
    whois
    dnsutils
    mtr
    traceroute

    # other apps
    veracrypt
    proton-vpn
    firefox
    jrnl

    # other
    udiskie
    fastfetch
    wget
    cava
    baobab
    proxmox-backup-client
  ];
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "catppuccin-mocha";
  };

  programs.neovim.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
}
