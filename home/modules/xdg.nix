{config, ...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/usr/local/share"
  ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # File manager
      "inode/directory" = ["org.gnome.Nautilus.desktop"];

      # Text / source code
      "text/plain" = ["dev.zed.Zed.desktop"];
      "text/markdown" = ["md.obsidian.Obsidian.desktop"];
      "text/x-python" = ["dev.zed.Zed.desktop"];
      "text/x-rust" = ["dev.zed.Zed.desktop"];
      "application/json" = ["dev.zed.Zed.desktop"];
      "application/xml" = ["dev.zed.Zed.desktop"];

      # Images
      "image/jpeg" = ["org.gnome.Loupe.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
      "image/gif" = ["org.gnome.Loupe.desktop"];
      "image/webp" = ["org.gnome.Loupe.desktop"];
      "image/svg+xml" = ["org.gnome.Loupe.desktop"];
      "image/bmp" = ["org.gnome.Loupe.desktop"];
      "image/tiff" = ["org.gnome.Loupe.desktop"];
      "image/avif" = ["org.gnome.Loupe.desktop"];

      # Video
      "video/mp4" = ["mpv.desktop"];
      "video/x-matroska" = ["mpv.desktop"];
      "video/webm" = ["mpv.desktop"];
      "video/x-msvideo" = ["mpv.desktop"];
      "video/quicktime" = ["mpv.desktop"];
      "video/mpeg" = ["mpv.desktop"];

      # Audio
      "audio/mpeg" = ["mpv.desktop"];
      "audio/flac" = ["mpv.desktop"];
      "audio/ogg" = ["mpv.desktop"];
      "audio/wav" = ["mpv.desktop"];
      "audio/x-wav" = ["mpv.desktop"];

      # Office documents
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/msword" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.ms-excel" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];
      "application/vnd.ms-powerpoint" = [
        "org.onlyoffice.desktopeditors.desktop"
      ];

      # Archives
      "application/zip" = ["org.gnome.FileRoller.desktop"];
      "application/x-tar" = ["org.gnome.FileRoller.desktop"];
      "application/x-7z-compressed" = ["org.gnome.FileRoller.desktop"];
      "application/x-rar" = ["org.gnome.FileRoller.desktop"];
      "application/gzip" = ["org.gnome.FileRoller.desktop"];

      # Browser
      "text/html" = ["org.mozilla.firefox.desktop"];
      "x-scheme-handler/http" = ["org.mozilla.firefox.desktop"];
      "x-scheme-handler/https" = ["org.mozilla.firefox.desktop"];
      "x-scheme-handler/about" = ["org.mozilla.firefox.desktop"];
      "x-scheme-handler/unknown" = ["org.mozilla.firefox.desktop"];
    };
  };
}
