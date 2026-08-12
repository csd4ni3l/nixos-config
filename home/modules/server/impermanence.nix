{pkgs, ...}: {
  # NOTE: HOME path is autoincluded, no need to worry
  home.persistence."/persist" = {
    hideMounts = true;
    directories = [
      ".local/bin"
      "containers"
      ".ssh"
    ];
  };
}
