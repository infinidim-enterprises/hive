{ inputs, cell, ... }:
{
  common = _: {
    imports = [
      # inputs.sops-nix-mod.nixosModules.sops
      inputs.sops-nix.nixosModules.sops
      ./_common.nix
    ];

    # sops.gnupg.home = "/var/lib/sops";
    # sops.gnupg.sshKeyPaths = [ "/etc/ssh_keys/ssh_host_rsa_key" ];

    sops.secrets = {
      root-password = {
        key = "root-password";
        sopsFile = ./sops/nixos-common.yaml;
        neededForUsers = true;
      };
    };
  };
}
