# {self, ...}: {
#   flake.nixosModules.HardeningEnvironmentLockdown = {
#     pkgs,
#     config,
#     lib,
#     ...
#   }: let
#     script = pkgs.writeShellScript "envlockdown" ''
#       export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.util-linux pkgs.glibc.bin]}"

#       user="$1";
#       home="/home/$user"

#       [ -n "$home" ] && [ -d "$home" ] || exit 0

#       hm_root=""

#       for p in .zshenv .bashrc .profile; do
#           r="$(readlink -f "$home/$p" 2>/dev/null || true)"
#           case "$r" in /nix/store/*-home-manager-files/*) hm_root="''${r%/*}"; break;; esac
#       done

#       targets=".zshenv .bashrc .bash_profile .bash_login .bash_logout .profile .config/zsh/.zshenv .config/zsh/.zprofile .config/zsh/.zshrc .config/zsh/.zlogin .config/zsh/.zlogout"

#       mnt() {
#           mountpoint -q "$2" 2>/dev/null || mount --bind "$1" "$2" 2>/dev/null;
#           mount -o remount,bind,ro,nosuid "$2" 2>/dev/null || true;
#       }

#       case "$2" in
#           unlock)
#               for t in $targets "$home/.config/environment.d"; do
#                   mountpoint -q "$t" 2>/dev/null && umount "$t" 2>/dev/null || true;
#               done ;;
#           lock)
#               mkdir -p "$home/.config/environment.d"
#               if [ -n "$hm_root" ] && [ -d "$hm_root/.config/environment.d" ]; then
#                   mnt "$hm_root/.config/environment.d" "$home/.config/environment.d"
#               else
#                   mkdir -p /var/lib/envlockdown/empty-$user && mnt /var/lib/envlockdown/empty-$user "$home/.config/environment.d";
#               fi

#               [ -n "$hm_root" ] || exit 0

#               for t in $targets; do
#                   [ -e "$hm_root/$t" ] && mnt "$hm_root/$t" "$home/$t";
#               done ;;
#       esac
#     '';
#   in {
#     systemd.services = lib.mapAttrs' (user: _:
#       lib.nameValuePair "home-manager-${user}" {
#         serviceConfig = {
#           ExecStartPre = ["-+${script} ${user} unlock"];
#           ExecStartPost = ["-+${script} ${user} lock"];
#         };
#       })
#     config.home-manager.users;
#   };
# }

{self, ...}: {
  flake.nixosModules.HardeningEnvironmentLockdown = {
    pkgs,
    config,
    lib,
    ...
  }: {
    # TODO: make this actually work
  };
}
