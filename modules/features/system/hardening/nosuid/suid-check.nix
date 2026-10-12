{self, ...}: {
  flake.nixosModules.HardeningSUIDCheck = {config, lib, ...}: let
    # NOTE: probably gonna avoid but safe to keep
    allowSetuid = [];

    offenders = builtins.filter (name: !(lib.elem name allowSetuid)) (
      builtins.filter (
        name:
        (config.security.wrappers.${name}.setuid or false)
        || (config.security.wrappers.${name}.setgid or false)
      )
      (builtins.attrNames config.security.wrappers)
    );
  in {
    assertions = [
      {
        assertion = offenders == [];
        message = ''
          security.wrappers contains SUID/SGID wrappers: ${lib.concatStringsSep ", " offenders}.
          These are not allowed, for security reasons. Please check the config, and use capabilities instead.
        '';
      }
    ];
  };
}
