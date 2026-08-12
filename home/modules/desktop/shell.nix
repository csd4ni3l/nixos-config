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

    zsh.shellAliases.rebuild = "run0 nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec --accept-flake-config";

    cava.enable = true;
  };
}
