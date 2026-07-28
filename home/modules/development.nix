{ pkgs, inputs, ... }: {
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.neovim.enable = true;
  programs.lazyvim = {
    enable = true;

    installCoreDependencies = true;

    extras = {
      lang.nix.enable = true;
      lang.python = {
        enable = true;
        installDependencies = true;
      };
      lang.rust = {
        enable = true;
        installDependencies = true;
      };
      lang.json.enable = true;
      lang.markdown.enable = true;
      lang.sql.enable = true;
      lang.toml.enable = true;
      lang.yaml.enable = true;
      lang.docker.enable = true;
    };

    extraPackages = with pkgs; [
      # LSP
      pyright
      nixd

      # formatter
      alejandra
    ];

    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      nix
      python
      rust
    ];
  };

  programs.zed-editor = {
    enable = true;
    defaultEditor = true;
    extensions = [
      "catppuccin"
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
    zola # NOTE: my preferred static site generator, written in Rust
  ];
}
