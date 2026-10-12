{pkgs, ...}: {
  home.persistence."/persist" = {
    hideMounts = true;
    directories = [
      ".local/bin"
      ".local/share/containers"
      ".local/share/zoxide"
      "containers"
      ".ssh"
      ".config/sops"
    ];
  };
}
