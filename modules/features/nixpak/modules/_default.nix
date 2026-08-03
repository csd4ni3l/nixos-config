{
  module = {
    config,
    lib,
    pkgs,
    sloth,
    ...
  }: {
    config = {
      bubblewrap = {
        bind.ro = [
          "/run/current-system"
          "/nix/store"
          "/nix/var"
          [ "/etc/os-release" "/etc/os-release" ]
          [ "/etc/nsswitch.conf" "/etc/nsswitch.conf" ]
          [ "/etc/host.conf" "/etc/host.conf" ]
          [ "/etc/gai.conf" "/etc/gai.conf" ]
          [ "/etc/hosts" "/etc/hosts" ]
          [ "/etc/passwd" "/etc/passwd" ]
          [ "/etc/group" "/etc/group" ]
          [ "/etc/localtime" "/etc/localtime" ]
          "/etc/profiles"
          "/etc/static/profiles"
          "/lib"
          "/lib64"
          (sloth.concat' "/etc/static/profiles/per-user" (sloth.env "USER"))
          (sloth.concat' "/etc/profiles/per-user" (sloth.env "USER"))
        ];
        tmpfs = ["/tmp"];
        newSession = true;
        dieWithParent = true;
        env = {
          COLOR_SCHEME = "prefer-dark";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          GTK_THEME = "Catppuccin-Mocha-Standard-Blue";
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "24";
        };
      };
    };
  };
}
