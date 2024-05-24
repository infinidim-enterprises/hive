{ inputs, cell, ... }:

let
  # sshKeyPaths =
  /*
    map (e: e.persistentStoragePath + e.filePath) (filter (e: hasSuffix "ssh_host_rsa_key" e.filePath) (flatten (mapAttrsToList (k: v: v.files) Flake.nixosConfigurations.nixos-asbleg.config.environment.persistence)))
  */
in
{
  common = { pkgs, lib, config, ... }:
    let
      inherit (lib // builtins)
        map
        mkIf
        elem
        filter
        flatten
        mkForce
        mkMerge
        hasAttrByPath
        mapAttrsToList;
      isImpermanence =
        (hasAttrByPath [ "persistence" ] config.environment) &&
        (config.environment.persistence != { });
      isOpenssh = config.services.openssh.enable;
      opensshServiceKeyPaths = map (e: e.path)
        (filter (e: e.type == "rsa")
          config.services.openssh.hostKeys);
      impermanenceSshKeyPaths = map (e: e.persistentStoragePath + e.filePath)
        (filter (e: elem e.filePath opensshServiceKeyPaths)
          (flatten (mapAttrsToList (k: v: v.files)
            config.environment.persistence)));
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      config = mkMerge [
        (mkIf (isOpenssh && isImpermanence) {
          sops.gnupg.sshKeyPaths = impermanenceSshKeyPaths;
        })

        (mkIf (isOpenssh && !isImpermanence) {
          sops.gnupg.sshKeyPaths = opensshServiceKeyPaths;
        })

        {
          sops.age.sshKeyPaths = mkForce [ ]; # Not using age!
          environment.systemPackages = [ pkgs.sops ];

          sops.secrets = {
            root-password = {
              key = "root-password";
              sopsFile = ./sops/nixos-common.yaml;
              neededForUsers = true;
            };
          };
        }
      ];

    };
}
