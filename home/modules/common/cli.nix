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

        # Nord zsh-syntax-highlighting theme
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
        typeset -gA ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[comment]='fg=#616E88'
        ZSH_HIGHLIGHT_STYLES[alias]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[function]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[command]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[precommand]='fg=#EBCB8B,italic'
        ZSH_HIGHLIGHT_STYLES[builtin]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#EBCB8B'
        ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#BF616A'
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#B48EAD'
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#A3BE8C'
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#A3BE8C'
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[assign]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#BF616A'
        ZSH_HIGHLIGHT_STYLES[path]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[globbing]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#B48EAD'
        ZSH_HIGHLIGHT_STYLES[redirection]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[default]='fg=#D8DEE9'
        ZSH_HIGHLIGHT_STYLES[cursor]='fg=#D8DEE9'
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
