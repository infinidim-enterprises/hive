{ inputs, cell, ... }:
rec {
  # agenix = { lib, config, ... }: # TODO: impermanence agenix
  #   let inherit (lib) mkIf mkDefault hasAttrByPath; in
  #   mkIf ((hasAttrByPath [ "age" ] config) && config.services.openssh.enable) {

  #     age.identityPaths = mkDefault [
  #       "/persist/etc/ssh/ssh_host_ed25519_key"
  #       "/persist/etc/ssh/ssh_host_rsa_key"
  #     ];

  #     environment.persistence."/persist".files = mkDefault [
  #       "/etc/ssh/ssh_host_ed25519_key"
  #       "/etc/ssh/ssh_host_rsa_key"
  #     ];
  #   };

  default = { lib, config, ... }:
    let inherit (lib) mkIf mkAfter any hasAttr; in
    {
      boot.initrd.postDeviceCommands = mkAfter ''
        zfs rollback -r ${config.fileSystems."/".device}@blank
      '';

      fileSystems."/persist".neededForBoot = true;
      imports = [ inputs.impermanence.nixosModules.impermanence ];
      environment.persistence."/persist" = {
        directories = with config; [
          "/var/log"

          (mkIf (networking.wireless.enable || hardware.bluetooth.enable)
            "/var/lib/systemd/rfkill")

          (mkIf networking.networkmanager.enable
            "/etc/NetworkManager/system-connections")

          (mkIf hardware.bluetooth.enable
            "/var/lib/bluetooth")

          (mkIf services.xserver.displayManager.lightdm.enable
            "/var/cache/lightdm")

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
          [ (mkIf (cell.lib.isZfs config) "/etc/machine-id") ] ++
          [
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_rsa_key"
          ];
      };
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
