{ inputs, cell, ... }:
rec {

  default = { lib, config, ... }:
    let
      inherit (lib)
        any
        mkIf
        mkAfter
        hasAttr
        optional
        optionals;
    in
    {
      boot.initrd.postDeviceCommands = mkAfter ''
        zfs rollback -r ${config.fileSystems."/".device}@blank
      '';

      fileSystems."/".neededForBoot = true;
      fileSystems."/persist".neededForBoot = true;

      imports = [ inputs.impermanence.nixosModules.impermanence ];
      environment.persistence."/persist" = {
        hideMounts = true;

        directories = with config; [
          "/var/log"

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
          (optionals config.services.openssh.enable
            (map (e: e.path) config.services.openssh.hostKeys));
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
