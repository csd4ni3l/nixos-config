{
  pkgs,
  config,
  ...
}: {
  programs = {
    kitty = {
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

    zsh = {
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
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        export PATH="$HOME/.wakatime:$PATH"
        eval "$(terminal-wakatime init)"
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

    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "catppuccin_mocha";
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "${config.nixcfgs.git_username}";
          email = "${config.nixcfgs.git_email}";
        };
        pull.rebase = true;
        init.defaultBranch = "main";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    lazygit.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    htop.enable = true;
    btop.enable = true;
    cava.enable = true;
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
    tree
    jq
    unzip
    toolbox
    tldr
    fastfetch
    wget
  ];
}
