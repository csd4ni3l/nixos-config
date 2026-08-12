{pkgs, config, ...}: {
  programs = {
    uv.enable = true;
    opencode = {
      enable = true;
      package = null; # NOTE: nixpak is used instead
    };
    zed-editor = {
      enable = true;
      package = null; # NOTE: nixpak is used instead
      defaultEditor = false;
      extensions = [
        "catppuccin"
        "html"
        "log"
        "nix"
        "toml"
        "dockerfile"
        "sql"
        "make"
        "hackatime"
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
          favorite_models = [];
          model_parameters = [];
        };
        cli_default_open_behavior = "new_window";
        ui_font_size = 16;
        buffer_font_size = 15;
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "zeditor --wait";
    VISUAL = "zeditor --wait";
  };

  sops.secrets."wakatime-api-url" = {};
  sops.secrets."wakatime-api-key" = {};
  sops.secrets."wakatime-hostname" = {};

  sops.templates."wakatime-cfg" = {
    path = "${config.home.homeDirectory}/.wakatime.cfg";
    content = ''
      api_url = ${config.sops.placeholder."wakatime-api-url"}
      api_key = ${config.sops.placeholder."wakatime-api-key"}
      hostname = ${config.sops.placeholder."wakatime-hostname"}
      heartbeat_rate_limit_seconds = 30
      sync_ai_disabled = true
    '';
  };

  home.packages = with pkgs; [
    rustup
    ccache
    mold
    clang
    gdb
    gnumake
    xorriso
    zola # NOTE: my preferred static site generator, written in Rust

    # LSP
    pyright
    nixd
    nil

    # formatter
    alejandra
    tombi
  ];
}
