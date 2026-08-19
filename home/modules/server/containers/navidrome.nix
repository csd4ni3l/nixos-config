{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.navidrome-playlists = {
    Unit = {
      Description = "Navidrome Playlist Auto-Updater";
      After = ["network.target"];
    };
    Service = {
      ExecStart = "${pkgs.python3.withPackages (ps: [ps.watchdog])}/bin/python3 ${config.home.homeDirectory}/containers/navidrome/music/update-playlists.py";
      WorkingDirectory = "${config.home.homeDirectory}/containers/navidrome/music/";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/navidrome/data"
    "${config.home.homeDirectory}/containers/navidrome/music"
  ];

  home.file."containers/navidrome/music/update-playlists.py".text = ''
    #!/usr/bin/env python3

    import os
    import time
    import threading
    from pathlib import Path
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    MUSIC_ROOT = Path("${config.home.homeDirectory}/containers/navidrome/music")

    AUDIO_EXTENSIONS = {".mp3", ".flac", ".wav", ".aac", ".ogg", ".m4a", ".opus"}

    def is_audio_file(file_path: Path) -> bool:
        return file_path.suffix.lower() in AUDIO_EXTENSIONS

    def generate_playlist(directory: Path):
        if not directory.is_dir():
            return

        playlist_name = directory.name + ".m3u"
        playlist_path = MUSIC_ROOT / playlist_name

        audio_files = []

        for root, _, files in os.walk(directory):
            for file in files:
                file_path = Path(root) / file
                if is_audio_file(file_path):
                    rel_path = file_path.relative_to(MUSIC_ROOT)
                    audio_files.append(str(rel_path))

        audio_files.sort()
        content = "\n".join(audio_files) + "\n"

        # Only write if changed
        if playlist_path.exists():
            try:
                with open(playlist_path, "r", encoding="utf-8") as f:
                    if f.read() == content:
                        return
            except Exception:
                pass

        with open(playlist_path, "w", encoding="utf-8") as f:
            f.write(content)

        print(f"[UPDATED] {playlist_path}")


    def generate_all_playlists():
        for item in MUSIC_ROOT.iterdir():
            if item.is_dir():
                generate_playlist(item)


    class MusicEventHandler(FileSystemEventHandler):
        def __init__(self):
            self._timer = None
            self._lock = threading.Lock()

        def _trigger_update(self):
            print("[INFO] Updating playlists...")
            generate_all_playlists()

        def on_any_event(self, event):
            path = Path(event.src_path)

            if path.suffix == ".m3u":
                return

            self._trigger_update()

    def main():
        print("[START] Generating initial playlists...")
        generate_all_playlists()

        event_handler = MusicEventHandler()
        observer = Observer()
        observer.schedule(event_handler, str(MUSIC_ROOT), recursive=True)
        observer.start()

        print("[WATCHING] Waiting for changes...")

        try:
            while True:
                time.sleep(5)
        except KeyboardInterrupt:
            observer.stop()

        observer.join()


    if __name__ == "__main__":
        main()
  '';

  home.file.".config/containers/systemd/navidrome.network".text = ''
    [Network]
    NetworkName=navidrome
  '';

  home.file.".config/containers/systemd/navidrome.container".text = ''
    [Unit]
    Description=Navidrome Container
    After=network-online.target

    [Container]
    ContainerName=navidrome
    AutoUpdate=registry
    UserNS=keep-id
    Network=navidrome.network
    Image=docker.io/deluan/navidrome:latest

    Volume=%h/containers/navidrome/data:/data:Z
    Volume=%h/containers/navidrome/music:/music:ro

    PublishPort=127.0.0.1:56001:4533

    Environment=ND_DATAFOLDER=/data
    Environment=ND_MUSICFOLDER=/music
    Environment=ND_SCANNER_SCHEDULE="* * * * *"
    Environment=ND_PLUGINS_ENABLED=true

    [Service]
    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
