{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."forgejo-runner-connection-url" = {};
  sops.secrets."forgejo-runner-uuid" = {};
  sops.secrets."forgejo-runner-token" = {};

  sops.templates."forgejo-runner-config" = {
    path = "${config.home.homeDirectory}/containers/forgejo-runner/data/runner-config.yml";
    content = ''
      log:
        level: info
        job_level: info

      runner:
        file: .runner
        capacity: 1
        timeout: 3h
        shutdown_timeout: 3h
        insecure: false
        fetch_timeout: 30s
        fetch_interval: 2s
        report_interval: 1s
        labels:
          - ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest

      container:
        network: ""
        enable_ipv6: false
        privileged: false
        options:
        workdir_parent:
        valid_volumes: []
        docker_host: unix:///var/run/docker.sock
        force_pull: false
        force_rebuild: false

      host:
        workdir_parent:

      server:
        connections:
          forgejo:
            url: ${config.sops.placeholder."forgejo-runner-connection-url"}
            uuid: ${config.sops.placeholder."forgejo-runner-uuid"}
            token: ${config.sops.placeholder."forgejo-runner-token"}
    '';
  };

  home.file.".config/containers/systemd/forgejo-runner.container".text = ''
    [Unit]
    Description=Forgejo Runner container
    After=network-online.target

    [Container]
    AutoUpdate=registry
    Image=data.forgejo.org/forgejo/runner:13

    Environment=DOCKER_HOST=unix:///var/run/docker.sock

    Volume=%h/containers/forgejo-runner/data:/data:Z
    Volume=/run/user/%U/podman/podman.sock:/var/run/docker.sock:rw

    [Install]
    WantedBy=multi-user.target default.target

    [Service]
    Restart=always
  '';
}
