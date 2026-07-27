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
      rebuild = "sudo nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec";
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
