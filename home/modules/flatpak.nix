{ pkgs, ... }: {
  services = {
    flatpak = {
      enable = true;
      update.onActivation = true; # automatically update on reboot
      overrides.files = [
        ./cfg/flatpak-overrides/org.prismlauncher.PrismLauncher
        ./cfg/flatpak-overrides/app.twintaillauncher.ttl
        ./cfg/flatpak-overrides/com.github.tchx84.Flatseal
        ./cfg/flatpak-overrides/com.logseq.Logseq
        ./cfg/flatpak-overrides/com.obsproject.Studio
        ./cfg/flatpak-overrides/io.missioncenter.MissionCenter
        ./cfg/flatpak-overrides/md.obsidian.Obsidian
        ./cfg/flatpak-overrides/net.mullvad.MullvadBrowser
        ./cfg/flatpak-overrides/org.fedoraproject.MediaWriter
        ./cfg/flatpak-overrides/org.getmonero.Monero
        ./cfg/flatpak-overrides/org.ghidra_sre.Ghidra
        ./cfg/flatpak-overrides/org.kde.kdenlive
        ./cfg/flatpak-overrides/org.nicotine_plus.Nicotine
        ./cfg/flatpak-overrides/org.onlyoffice.desktopeditors
      ];
      packages = [
        "org.prismlauncher.PrismLauncher"
        "app.twintaillauncher.ttl"
        "com.github.tchx84.Flatseal"
        "com.logseq.Logseq"
        "com.obsproject.Studio"
        "com.obsproject.Studio.Plugin.Gstreamer"
        "com.obsproject.Studio.Plugin.GStreamerVaapi"
        "io.missioncenter.MissionCenter"
        "md.obsidian.Obsidian"
        "net.mullvad.MullvadBrowser"
        "org.fedoraproject.MediaWriter"
        "org.getmonero.Monero"
        "org.ghidra_sre.Ghidra"
        "org.kde.kdenlive"
        "org.nicotine_plus.Nicotine"
        "org.onlyoffice.desktopeditors"
        "org.torproject.torbrowser-launcher"
        "net.portswigger.BurpSuite-Community"
      ];
    };
  };
}
