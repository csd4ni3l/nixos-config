{pkgs, ...}: {
  # NOTE: HOME path is autoincluded, no need to worry
  home.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "Music"
      "Pictures"
      "Documents"
      "Projects"
      "Videos"
      "programs"
      "retro-game-roms"
      "Templates"

      ".rustup/toolchains"
      ".rustup/update-hashes"

      ".config/Code" # NOTE: I don't use VSCode anymore and it is not installed but i might need my old data
      ".config/mozilla"
      ".config/Proton"
      ".config/dconf"
      ".config/sops"

      ".local/bin"

      ".local/state/wireplumber"

      ".local/share/zoxide"
      ".local/share/uv"
      ".local/share/anime-game-launcher"
      ".local/share/opentui"
      ".local/share/opencode/snapshot"
      ".local/share/zed/external_agents"
      ".local/share/jrnl"
      ".local/share/nix"
      ".local/share/PrismLauncher"
      ".local/share/keyrings"
      ".local/share/Steam"

      ".var/app"

      ".wakatime"
      ".ssh"
    ];
    files = [
      ".rustup/settings.toml"

      ".local/share/icons/default/index.theme"
      ".local/share/opencode/account.json"
      ".local/share/opencode/auth.json"
      ".local/share/opencode/opencode.db"
      ".local/share/opencode/opencode-stable.db"

      ".local/state/opencode/model.json"

      ".config/proxmox-backup/fingerprints"
      ".config/gtk-3.0/bookmarks"
    ];
  };
}
