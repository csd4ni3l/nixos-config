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
      "image/bmp" = ["org.gnome.Loupe.desktop"];
      "image/tiff" = ["org.gnome.Loupe.desktop"];
      "image/avif" = ["org.gnome.Loupe.desktop"];
      "image/svg+xml" = ["ai.storyteller.vectorcraft.desktop"];

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
        "ai.storyteller.wordcraft.desktop"
      ];
      "application/msword" = [
        "ai.storyteller.wordcraft.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = [
        "ai.storyteller.wordcraft.desktop"
      ];
      "application/vnd.oasis.opendocument.text" = [
        "ai.storyteller.wordcraft.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
        "ai.storyteller.gridcraft.desktop"
      ];
      "application/vnd.ms-excel" = [
        "ai.storyteller.gridcraft.desktop"
      ];
      "application/vnd.ms-excel.sheet.macroEnabled.12" = [
        "ai.storyteller.gridcraft.desktop"
      ];
      "application/vnd.oasis.opendocument.spreadsheet" = [
        "ai.storyteller.gridcraft.desktop"
      ];
      "text/csv" = ["ai.storyteller.gridcraft.desktop"];
      "text/tab-separated-values" = ["ai.storyteller.gridcraft.desktop"];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
        "ai.storyteller.deckcraft.desktop"
      ];
      "application/vnd.openxmlformats-officedocument.presentationml.template" = [
        "ai.storyteller.deckcraft.desktop"
      ];
      "application/vnd.ms-powerpoint" = [
        "ai.storyteller.deckcraft.desktop"
      ];
      "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = [
        "ai.storyteller.deckcraft.desktop"
      ];

      # Documents and drawings
      "application/pdf" = ["ai.storyteller.pdfcraft.desktop"];
      "application/x-deckcraft" = ["ai.storyteller.deckcraft.desktop"];
      "application/rtf" = ["ai.storyteller.wordcraft.desktop"];
      "text/rtf" = ["ai.storyteller.wordcraft.desktop"];

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
