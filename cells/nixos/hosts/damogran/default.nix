{ inputs, cell, ... }:
let
  inherit (builtins) toString baseNameOf;
  system = "aarch64-linux";
in

rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixos-24-05 {
      inherit system;
      config.allowUnfree = true;
      overlays =
        cell.overlays.emacs
        ++ (inputs.nixpkgs-lib.lib.subtractLists [ inputs.nixd.overlays.default ]
          cell.overlays.base)
        ++ [
          inputs.raspberry-pi-nix.overlays.core
          inputs.raspberry-pi-nix.overlays.libcamera
        ];
    };
  };

  imports =
    cell.nixosSuites.cli
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager
      { home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }]; }

      (import ./_hardwareProfile.nix { inherit inputs cell; })

      cell.nixosProfiles.services.minidlna-and-torrent

      ({ pkgs, ... }:
        {
          systemd.network.networks.local-eth.matchConfig.Name = "end0";
          networking.wireless.enable = false;
          networking.networkmanager.enable = false;
        })

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:1a:ff";
        # deploy.params.lan.ipv4 = "10.11.1.122/24";
        deploy.params.lan.ipv4 = "192.168.1.133/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23e7e5ff";
      }

      ({ pkgs, ... }:
        {
          systemd.network.networks.lan = {
            addresses = [
              (cell.lib.networkdSyntax {
                inherit pkgs;
                Address = "192.168.1.133/24";
              })
            ];
            networkConfig.Gateway = "192.168.1.1";
          };
        })

    ];
}
