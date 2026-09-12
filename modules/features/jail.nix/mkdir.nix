{
  flake.nixosModules.JailDirs = {
    pkgs,
    lib,
    ...
  }: let
    dirs = [
      ".bitmonero"
      ".cache/ccache"
      ".cache/go-build"
      ".cache/mozilla"
      ".cache/uv"
      ".cargo"
      ".config/jrnl"
      ".config/mozilla"
      ".config/onlyoffice"
      ".config/opencode"
      ".config/OrcaSlicer"
      ".config/zed"
      ".config/zsh"
      ".config/tor-browser"
      ".config/obs-studio"
      ".go"
      ".local/share/anime-game-launcher"
      ".local/share/jrnl"
      ".local/share/onlyoffice"
      ".local/share/opencode"
      ".local/share/PrismLauncher"
      ".local/share/Steam"
      ".local/share/uv"
      ".local/share/zed"
      ".local/state/opencode"
      ".p2pool"
      ".rustup"
      ".steam"
      ".wakatime"
      "Documents"
      "Documents/Monero"
      "Documents/ObsidianVault"
      "Downloads"
      "Music"
      "Projects"
      "Projects/3D"
      "Projects/Programming"
      "Videos"
      "Videos/OBS"
    ];
    cmd = "${pkgs.bash}/bin/bash -c 'mkdir -p \"$HOME/${lib.concatStringsSep "\" \"$HOME/" dirs}\"'";
  in {
    systemd.user.services.jail-mkdir = {
      description = "Create persistent directories for jailed applications";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = cmd;
      };
    };
  };
}
