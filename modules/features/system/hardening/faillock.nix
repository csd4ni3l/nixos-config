{...}: {
  flake.nixosModules.HardeningFaillock = {
    pkgs,
    config,
    lib,
    ...
  }: let
    faillock = "${config.security.pam.package}/lib/security/pam_faillock.so";

    services = [
      "login"
      "sudo"
      "su"
      "passwd"
      "sshd"
      "polkit-1"
    ];

    mkRules = svc: {
      rules.auth = {
        "faillock-preauth" = {
          order = config.security.pam.services.${svc}.rules.auth.unix.order - 100;
          control = "required";
          modulePath = faillock;
          args = ["preauth"];
        };
        "faillock-authfail" = {
          order = config.security.pam.services.${svc}.rules.auth.unix.order + 10;
          control = "[default=die]";
          modulePath = faillock;
          args = ["authfail"];
        };
        "faillock-authsucc" = {
          order = config.security.pam.services.${svc}.rules.auth.unix.order + 20;
          control = "sufficient";
          modulePath = faillock;
          args = ["authsucc"];
        };
      };
      rules.account.faillock = {
        order = config.security.pam.services.${svc}.rules.account.unix.order - 100;
        control = "required";
        modulePath = faillock;
      };
    };
  in {
    environment.etc."security/faillock.conf".text = ''
      dir = /var/run/faillock
      audit
      silent
      even_deny_root
      deny = 3
      fail_interval = 900
      unlock_time = 600
      root_unlock_time = 600
    '';

    systemd.tmpfiles.rules = [
      "d /var/run/faillock 0755 root root -"
    ];

    environment.systemPackages = [pkgs.pam];

    security.pam.services = lib.genAttrs services mkRules;
  };
}
