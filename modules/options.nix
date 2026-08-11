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
  };
in {
  flake.nixosModules.options = nixcfgsOptions;
  flake.homeModules.options = nixcfgsOptions;
}
