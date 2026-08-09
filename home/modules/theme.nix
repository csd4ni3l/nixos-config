{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];

  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";
    accent = "blue";
    bat.enable = true;
    btop.enable = true;
    cava.enable = true;
    delta.enable = true;
    eza.enable = true;
    fzf.enable = true;
    kitty.enable = true;
    lazygit.enable = true;
    mangohud.enable = true;
    mpv.enable = true;
    opencode.enable = true;
    yazi.enable = true;
    zsh-syntax-highlighting.enable = true;
    kvantum.enable = false;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
