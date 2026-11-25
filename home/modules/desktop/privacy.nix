{pkgs, ...}: {
  home.packages = with pkgs; [
    proton-vpn
    # onionshare-gui
  ];

  # Autostart Proton VPN in the desktop session.
  xdg.configFile."autostart/protonvpn.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Proton VPN
    Comment=Proton VPN GUI
    Exec=${pkgs.proton-vpn}/bin/protonvpn-app
    Terminal=false
    Categories=Network;VPN;
    X-GNOME-Autostart-enabled=true
  '';
}
