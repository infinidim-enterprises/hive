{ inputs, cell, ... }:

let
  # sshKeyPaths =
  /*
    map (e: e.persistentStoragePath + e.filePath) (filter (e: hasSuffix "ssh_host_rsa_key" e.filePath) (flatten (mapAttrsToList (k: v: v.files) Flake.nixosConfigurations.nixos-asbleg.config.environment.persistence)))
  */
in
{
  common = { lib, config, ... }:
    let
      inherit (lib)
        map
        mkIf
        filter
        flatten
        hasAttrByPath
        mapAttrsToList;
      isImpermanence = hasAttrByPath [ "persistence" ] config.envronment;
      isOpenssh = config.services.openssh.enable;
      # sshKeyPaths =
      #   if
      #   then
      #   else
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
        ./_common.nix
      ];

      # sops.gnupg.home = "/var/lib/sops";
      sops.gnupg.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_rsa_key" ];

      # sops.gnupg = { inherit sshKeyPaths; };

      sops.secrets = {
        root-password = {
          key = "root-password";
          sopsFile = ./sops/nixos-common.yaml;
          neededForUsers = true;
        };
      };
    };
}
