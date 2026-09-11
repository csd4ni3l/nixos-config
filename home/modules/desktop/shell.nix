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
        enable_audio_bell = false;
        confirm_os_window_close = -1;
      };
    };

    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "nordtron";
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

  home.sessionVariables.EZA_COLORS = "di=1;38;5;110:ln=38;5;81:ex=38;5;150:pi=38;5;179:so=38;5;167:bd=1;38;5;179:cd=1;38;5;179:or=38;5;167:*.zip=38;5;167:*.tar=38;5;167:*.gz=38;5;167:*.7z=38;5;167:*.rar=38;5;167";
}
