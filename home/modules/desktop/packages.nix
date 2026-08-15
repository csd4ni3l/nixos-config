{
  pkgs,
  config,
  ...
}: {
  programs = {
    jrnl = {
      enable = true;
      package = null;
      settings = {
        colors = {
          body = "none";
          date = "black";
          tags = "yellow";
          title = "cyan";
        };
        default_hour = 9;
        default_minute = 0;
        editor = "/run/current-system/sw/bin/nano";
        encrypt = true;
        highlight = true;
        indent_character = "|";
        journals = {
          default = {
            journal = "/home/${config.nixcfgs.username}/.local/share/jrnl/journal.txt";
          };
        };
        linewrap = 79;
        tagsymbols = "#@";
        template = false;
        timeformat = "%F %r";
        version = "v4.2";
      };
    };
  };

  home.packages = with pkgs; [
    bubblewrap
    udiskie
    baobab
    proxmox-backup-client
  ];
}
