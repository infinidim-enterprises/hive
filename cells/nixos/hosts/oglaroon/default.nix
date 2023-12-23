{
  inputs,
  cell,
  ...
}: let
  inherit (builtins) toString baseNameOf;
  system = "x86_64-linux";
in rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    pkgs = import inputs.latest {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      # overlays = cell.overlays.desktop;
      overlays = [
        inputs.cells.common.overlays.latest-overrides
      ];
    };
  };

  imports =
    [({config, ...}: (cell.lib.mkHome "vod" config.networking.hostName "zsh"))]
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager
      cell.hardwareProfiles.${baseNameOf ./.}
      cell.nixosProfiles.zfs

      cell.nixosProfiles.desktop.printer-kyocera

      cell.nixosProfiles.virtualization
      {boot.kernelModules = ["kvm-amd"];}

      # FIXME: inputs.cells.virtualization.nixosProfiles.docker
      inputs.cells.bootstrap.nixosProfiles.core.kernel.physical-access-system
      inputs.cells.networking.nixosProfiles.adguardhome
      (cell.nixosProfiles.default {boot = "grub-zfs";})
      ({lib, ...}: {
        boot.kernelParams = lib.mkAfter [
          # NOTE: This machine has 64 Gigs RAM
          "zfs.zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}"
        ];
      })
      ({pkgs, ...}: {
        systemd.network.networks.local-eth.matchConfig.Name = "eno1";
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
        services.udev.packages = with pkgs; [crda];
        environment.systemPackages = with pkgs; [networkmanagerapplet ventoy-full];
      })
      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:bf:ff";
        deploy.params.lan.ipv4 = "10.11.1.125/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e2ff";

        # services.redshift.brightness.night = "0.85";
        # services.redshift.brightness.day = "0.85";
      }
      ({
        lib,
        config,
        ...
      }: {
        systemd.network.networks.lan = {
          addresses = [{addressConfig.Address = "10.11.1.125/24";}];
          networkConfig.Gateway = "10.11.1.1";
          dns =
            if config.services.adguardhome.enable
            then config.services.adguardhome.settings.dns.bind_hosts
            else lib.mkDefault ["8.8.8.8"];
        };
      })
    ];
}
