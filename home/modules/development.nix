{ pkgs, ... }: {
  programs.zed-editor = {
    enable = true;
    defaultEditor = true;
    extensions = [
      "catpuccin"
      "html"
      "log"
      "nix"
      "toml"
      "dockerfile"
      "sql"
      "make"
    ];
    userSettings = {
        git_panel = {
            dock = "left";
        };
        outline_panel = {
            dock = "left";
        };
        project_panel = {
            dock = "left";
        };
        agent = {
            sidebar_side = "right";
            favorite_models = [ ];
            model_parameters = [ ];
        };
        cli_default_open_behavior = "new_window";
        ui_font_size = 16;
        buffer_font_size = 15;
        theme = {
            mode = "system";
            light = "One Light";
            dark = "Catppuccin Mocha";
        };
    };
  };

  programs.uv.enable = true;
  programs.opencode.enable = true;

  home.packages = with pkgs; [
    rustup
    ccache
    mold
    clang
    pipx
    gdb
    pkg-config
    direnv
    nix-direnv
    nil
    nixd
    gnumake
    xorriso
    nixfmt
  ];
}
