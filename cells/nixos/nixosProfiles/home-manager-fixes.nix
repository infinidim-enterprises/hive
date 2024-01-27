{ inputs, cell, ... }:
# NOTE: https://github.com/nix-community/home-manager/commit/b0651cc2173427857b172604f85da6afe69e1d41
#       The commit broke stuff here, the problem is the '-e' switch to bash in execStart script
{ config, lib, pkgs, ... }:
with lib;
mkIf (length (attrNames config.home-manager.users) > 0)
{
  systemd.services = mapAttrs'
    (_: usercfg: nameValuePair "home-manager-${usercfg.home.username}" {
      serviceConfig = lib.mkForce {
        User = usercfg.home.username;
        Type = "oneshot";
        RemainAfterExit = "yes";
        TimeoutStartSec = 90;
        SyslogIdentifier = "hm-activate-${usercfg.home.username}";

        ExecStart =
          let
            systemctl =
              "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} ${pkgs.systemd}/bin/systemctl";

            sed = "${pkgs.gnused}/bin/sed";

            exportedSystemdVariables = concatStringsSep "|" [
              "DBUS_SESSION_BUS_ADDRESS"
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "XAUTHORITY"
              "XDG_RUNTIME_DIR"
            ];

            setupEnv = pkgs.writeScript "hm-setup-env" ''
              #!${pkgs.runtimeShell} -l

              # The activation script is run by a login shell to make sure
              # that the user is given a sane environment.
              # If the user is logged in, import variables from their current
              # session environment.
              eval "$(
                ${systemctl} --user show-environment 2> /dev/null \
                | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
              )"
              exec "$1/activate"
            '';
          in
          "${setupEnv} ${usercfg.home.activationPackage}";
      };
    })
    config.home-manager.users;
}
