{ inputs, cell, ... }:
let
  inherit (builtins) baseNameOf;
in
rec {
  bee = {
    system = "x86_64-linux";
    # inherit (inputs.nixpkgs) system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixpkgs-unstable {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = with inputs.cells.common.overlays; [
        sources
        nixpkgs-unstable-overrides
        nixpkgs-master-overrides
      ];
    };
  };

  imports =
    cell.nixosSuites.base
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      ({ pkgs, ... }: {
        systemd.network.networks.local-eth.matchConfig.Name = "eno1";
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
        environment.systemPackages = with pkgs; [ networkmanagerapplet ];
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
      ({ lib, config, ... }: {
        systemd.network.networks.lan = {
          addresses = [{ addressConfig.Address = "10.11.1.125/24"; }];
          networkConfig.Gateway = "10.11.1.1";
          dns =
            if config.services.adguardhome.enable
            then config.services.adguardhome.settings.dns.bind_hosts
            else lib.mkDefault [ "8.8.8.8" ];
        };
      })
    ];
}
