{ inputs, cell, ... }:
rec {

  default = { lib, config, pkgs, utils, ... }:
    let
      inherit (utils) escapeSystemdPath;
      inherit (pkgs.callPackage "${inputs.impermanence}/lib.nix" { })
        concatPaths;
      inherit (lib)
        any
        mkIf
        mkAfter
        mkMerge
        hasAttr
        optional
        optionals
        mapAttrs'
        listToAttrs
        nameValuePair
        escapeShellArg;
      persistentStoragePath = "/persist";
      openSshHostKeys = map (e: e.path) config.services.openssh.hostKeys;
    in
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];
      config = mkMerge [
        {
          # boot.initrd.postDeviceCommands = mkAfter ''
          #   zfs rollback -r ${config.fileSystems."/".device}@blank
          # '';

          # NOTE: https://github.com/NixOS/nixpkgs/pull/208037
          boot.initrd.postResumeCommands = mkAfter ''
            zfs rollback -r ${config.fileSystems."/".device}@blank
          '';

          fileSystems."/".neededForBoot = true;
          fileSystems."${persistentStoragePath}".neededForBoot = true;

          environment.persistence."${persistentStoragePath}" = {
            hideMounts = true;

            directories = with config; [
              "/var/log"
              "/var/lib/nixos"

              (mkIf services.samba.enable
                "/var/lib/samba/usershares")

              # (mkIf sound.enable
              #   "/var/lib/alsa")

              (mkIf (networking.wireless.enable || hardware.bluetooth.enable)
                "/var/lib/systemd/rfkill")

              (mkIf networking.networkmanager.enable
                "/etc/NetworkManager/system-connections")

              (mkIf hardware.bluetooth.enable
                "/var/lib/bluetooth")

              # (mkIf services.xserver.displayManager.lightdm.enable
              #   "/var/cache/lightdm")

              (mkIf services.opensnitch.enable
                "/etc/opensnitchd/rules")

              (mkIf virtualisation.docker.enable
                "/var/lib/docker")

              (mkIf virtualisation.libvirtd.enable
                "/var/lib/libvirt")

              (mkIf services.zerotierone.enable "/var/lib/zerotier-one"
                # TODO: perhaps only keep identity.secret in /persist for zerotier
                # services.zerotierone.homeDir
              )
            ];

            files =
              (optional (cell.lib.isZfs config) "/etc/machine-id") ++
              (optionals config.services.openssh.enable openSshHostKeys);
          };
        }

        (mkIf config.services.openssh.enable (
          let
            overrides = listToAttrs (map
              (filePath: nameValuePair
                "persist-${escapeSystemdPath
                  (escapeShellArg (concatPaths [ persistentStoragePath filePath ]))}"
                { before = [ "sshd.service" ]; })
              openSshHostKeys);
          in
          { systemd.services = mapAttrs' nameValuePair overrides; }
        ))
      ];
    };

  vod = { lib, ... }: {
    imports = [ default ];

    environment.persistence."/persist" = {
      users.vod = {
        directories = [
          "Projects"
          "Documents"
          "Downloads"
          "Pictures"
          "Desktop"
          "Music"
          "Public"
          "Templates"
          "tmp"
          "Videos"
          "Logs"
          "keybase" # REVIEW: maybe use keybase nixos module instead of home-manager one?
          ".cache"
          ".local"
          ".ssh"
        ];
      };
    };
  };
}
