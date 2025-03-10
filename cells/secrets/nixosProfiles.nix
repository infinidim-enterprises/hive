{ inputs, cell, ... }:

{
  common = { pkgs, lib, config, ... }:
    let
      inherit (lib // builtins)
        map
        mkIf
        elem
        head
        filter
        flatten
        mkForce
        readDir
        mkMerge
        attrNames
        pathExists
        hasAttrByPath
        mapAttrsToList;
      isImpermanence = inputs.cells.nixos.lib.isImpermanence config;
      isOpenssh = config.services.openssh.enable;
      opensshServiceKeyPaths = map (e: e.path)
        (filter (e: e.type == "rsa")
          config.services.openssh.hostKeys);
      impermanenceSshKeyPaths = map (e: e.persistentStoragePath + e.filePath)
        (filter (e: elem e.filePath opensshServiceKeyPaths)
          (flatten (mapAttrsToList (k: v: v.files)
            config.environment.persistence)));

      path = ./sops/zerotier/${config.networking.hostName};

      zerotierKey =
        if pathExists path
        then head (attrNames (readDir path))
        else null;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      config = mkMerge [
        (mkIf isImpermanence {
          system.activationScripts.setupSecretsForUsers.deps = [
            "persist-files"
          ];
        })

        (mkIf (zerotierKey != null && config.services.zerotierone.enable) {
          sops.secrets.zerotierKey = {
            sopsFile = path + "/${zerotierKey}";
            restartUnits = [ "zerotierone.service" ];
            format = "binary";
          };
          services.zerotierone.privateKeyFile = config.sops.secrets.zerotierKey.path;
        })

        (mkIf (isOpenssh && isImpermanence) {
          sops.gnupg.sshKeyPaths = impermanenceSshKeyPaths;
        })

        (mkIf (isOpenssh && !isImpermanence) {
          sops.gnupg.sshKeyPaths = opensshServiceKeyPaths;
        })

        (mkIf (config.services.restic.backups != { }) {
          sops.secrets.rclone_conf = {
            sopsFile = ./sops/rclone.conf;
            format = "binary";
          };
          sops.secrets.restic_passwd = {
            key = "restic_passwd";
            sopsFile = ./sops/online-storage-systems.yaml;
          };

        })

        {
          sops.age.sshKeyPaths = mkForce [ ]; # NOTE: Not using age!
          environment.systemPackages = [ pkgs.sops ];

          sops.secrets.root-password = {
            key = "root-password";
            sopsFile = ./sops/nixos-common.yaml;
            neededForUsers = true;
          };
        }
      ];

    };
}
