{ pkgs, ... }: {
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
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
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
      rebuild = "run0 nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec --accept-flake-config";
      mount = "run0 mount";
      umount = "run0 umount";
      opencode = ''
        bwrap \
          --unshare-all \
          --share-net \
          --new-session \
          --die-with-parent \
          --ro-bind /nix /nix \
          --ro-bind /etc /etc \
          --dev /dev \
          --proc /proc \
          --ro-bind /run /run \
          --tmpfs /tmp \
          --tmpfs /home \
          --ro-bind "$HOME/.config/git" /tmp/config/git \
          --bind "$HOME/.local/share/opencode" /tmp/share/opencode \
          --bind "$HOME/.local/state/opencode" /tmp/state/opencode \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          --setenv HOME /tmp/home \
          --setenv XDG_CONFIG_HOME /tmp/config \
          --setenv XDG_CACHE_HOME /tmp/cache \
          --setenv XDG_DATA_HOME /tmp/share \
          --setenv XDG_STATE_HOME /tmp/state \
          --unsetenv SSH_AUTH_SOCK \
          opencode
      '';
    };
  };

  programs.starship = {
    enable = true;
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

  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
      };
    };
  };

  home.packages = with pkgs; [
    # shell env
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
    toolbox
    tldr
    fastfetch
    wget
    cava
  ];
}
