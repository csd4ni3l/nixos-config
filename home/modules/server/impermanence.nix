{pkgs, ...}: {
  # NOTE: HOME path is autoincluded, no need to worry
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
