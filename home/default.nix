{ pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home.username = "csd4ni3l";
  home.homeDirectory = "/home/csd4ni3l";
  home.stateVersion = "26.05";

  xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
  xdg.configFile."Mangohud/MangoHud.conf".source = ./config/mangohud/Mangohud.conf;

  xdg.user-dirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      XDG_DESKTOP_DIR = "$HOME/Desktop";
      XDG_DOCUMENTS_DIR = "$HOME/Documents";
      XDG_DOWNLOAD_DIR = "$HOME/Downloads";
      XDG_MUSIC_DIR = "$HOME/Music";
      XDG_PICTURES_DIR = "$HOME/Pictures";
      XDG_VIDEOS_DIR = "$HOME/Videos";
      XDG_PROJECTS_DIR = "$HOME/Projects";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["nautilus.desktop"];
      "image/*" = ["org.gnome.Loupe.desktop"];
      "video/mp4" = ["mpv.desktop"];
      "text/plain" = ["dev.zed.Zed.desktop"];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12.0;
      background_opacity = "0.95";
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
      eval "$(atuin init zsh)"
    '';

    shellAliases = {
      cat = "bat";
      ls = "eza";
      top = "btop";
      lg = "lazygit";
      yz = "yazi";
      ll = "eza -la";
      gs = "git status";
      rebuild = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      directory.truncation_length = 3;
      command_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
      };
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
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.noctalia = {
    enable = true;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "high-quality";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };

  services = {
    flatpak = {
      enable = true;
      update.onActivation = true; # automatically update on reboot
      overrides.files = [
        "./config/flatpak-overrides/app.twintaillauncher.ttl"
        "./config/flatpak-overrides/com.github.tchx84.Flatseal"
        "./config/flatpak-overrides/com.logseq.Logseq"
        "./config/flatpak-overrides/com.modrinth.ModrinthApp"
        "./config/flatpak-overrides/com.obsproject.Studio"
        "./config/flatpak-overrides/com.orcaslicer.OrcaSlicer"
        "./config/flatpak-overrides/io.missioncenter.MissionCenter"
        "./config/flatpak-overrides/md.obsidian.Obsidian"
        "./config/flatpak-overrides/net.mullvad.MullvadBrowser"
        "./config/flatpak-overrides/org.fedoraproject.MediaWriter"
        "./config/flatpak-overrides/org.getmonero.Monero"
        "./config/flatpak-overrides/org.ghidra_sre.Ghidra"
        "./config/flatpak-overrides/org.kde.kdenlive"
        "./config/flatpak-overrides/org.nicotine_plus.Nicotine"
        "./config/flatpak-overrides/org.onlyoffice.desktopeditors"
      ];
      packages = [
        "app.twintaillauncher.ttl"
        "com.github.tchx84.Flatseal"
        "com.logseq.Logseq"
        "com.modrinth.ModrinthApp"
        "com.obsproject.Studio"
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
    atuin
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

    # hacking
    metasploit
    nmap
    hydra
    ffuf
    gobuster
    wpscan
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
    baobab
    proxmox-backup-client
  ];

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
    platformTheme = "gtk3";
    style = "catppuccin-mocha";
  };

  programs.neovim.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
}
