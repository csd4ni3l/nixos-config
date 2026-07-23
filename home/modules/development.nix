{ pkgs, ... }: {
  home.packages = with pkgs; [
    # development
    rustup
    ccache
    mold
    clang
    uv
    zed-editor
    pipx
    opencode
    gdb
    pkg-config
    direnv
    nix-direnv
    nil
    nixd
    gnumake
    xorriso
  ];
}
