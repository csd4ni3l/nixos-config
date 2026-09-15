{self, ...}: let
  nixcfgsOptions = {lib, ...}: {
    options.nixcfgs.username = lib.mkOption {
      default = "user";
      example = "user";
      type = lib.types.strMatching "[a-z_][a-z0-9_-]*[$]?"; # Unix username regex
      description = ''
        Username for the single user of the system.
      '';
    };

    options.nixcfgs.firefox_full_dev_access = lib.mkEnableOption "firefox_full_dev_access";
    options.nixcfgs.kernel_module_lock = lib.mkEnableOption "kernel_module_lock";

    options.nixcfgs.git_email = lib.mkOption {
      default = "example@example.com";
      example = "example@example.com";
      type = lib.types.str;
      description = ''
        Email for git pushes
      '';
    };

    options.nixcfgs.git_username = lib.mkOption {
      default = "exampleuser";
      example = "exampleuser";
      type = lib.types.strMatching "[a-z_][a-z0-9_-]*[$]?"; # Unix username regex
      description = ''
        Username for git pushes
      '';
    };

    options.nixcfgs.firefox_cookie_allowlist = lib.mkOption {
      default = [];
      example = ["https://slack.com" "http://slack.com"];
      type = lib.types.listOf lib.types.str;
      description = ''
        Origins (including scheme) that are allowed to keep cookies.
        Cookies for all other origins are purged on shutdown.
      '';
    };

    options.nixcfgs.dnscrypt_server_names = lib.mkOption {
      default = [
        "quad9-dnscrypt-ip4-filter-pri"
        "adguard-dns-family"
        "cs-hungary"
        "cloudflare-secure"
      ];
      example = ["cloudflare" "quad9-dnscrypt-ip4-filter-pri"];
      type = lib.types.listOf lib.types.str;
      description = ''
        dnscrypt-proxy server names to use for DNS resolution.
      '';
    };
  };
in {
  flake.nixosModules.options = nixcfgsOptions;
  flake.homeModules.options = nixcfgsOptions;
}
