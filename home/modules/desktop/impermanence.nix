{pkgs, ...}: {
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

      ".rustup"

      ".config/Code" # NOTE: I don't use VSCode anymore and it is not installed but i might need my old data
      ".config/mozilla"
      ".config/Proton"
      ".config/dconf"
      ".config/sops"
      ".config/libvirt"
      ".config/slick"
      ".config/fluxercanary"
      ".config/deckcraft"
      ".config/gridcraft"
      ".config/pdfcraft"
      ".config/vectorcraft"
      ".config/wordcraft"

      ".local/bin"

      ".local/state/wireplumber"

      ".local/share/zoxide"
      ".local/share/uv"
      ".local/share/anime-game-launcher"
      ".local/share/opentui"
      ".local/share/opencode/snapshot"
      ".local/share/zed/db"
      ".local/share/zed/external_agents"
      ".local/share/jrnl"
      ".local/share/nix"
      ".local/share/PrismLauncher"
      ".local/share/keyrings"
      ".local/share/Steam"
      ".local/share/deckcraft"
      ".local/share/gridcraft"
      ".local/share/pdfcraft"
      ".local/share/vectorcraft"
      ".local/share/wordcraft"

      ".wakatime"
      ".ssh"
    ];
    files = [
      ".rustup/settings.toml"

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
