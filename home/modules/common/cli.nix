{
  pkgs,
  config,
  ...
}: {
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    lazygit.enable = true;
    ripgrep.enable = true;

    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
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
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      '';

      shellAliases = {
        cat = "bat --style=plain --pager=never";
        cd = "z";
        ls = "eza";
        top = "btop";
        lg = "lazygit";
        yz = "yazi";
        ll = "eza -la";
        gs = "git status";
        mount = "run0 mount";
        umount = "run0 umount";
      };
    };

    fd.enable = true;
    htop.enable = true;
    btop.enable = true;
    bat.enable = true;
    fzf.enable = true;
    eza.enable = true;
    yazi = {
      enable = true;
      settings = {
        mgr = {
          show_hidden = true;
        };
      };
    };
  };

  home.packages = with pkgs; [
    file
    tree
    jq
    unzip
    tldr
    fastfetch
    wget
    sqlite
    ncdu
  ];
}
