{ inputs, cell, ... }:
let
  inherit (builtins) baseNameOf;
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
          inputs.cells.common.overlays.minidlna
        ];
    };
  };

  imports =
    cell.nixosSuites.cli
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager

      (import ./_hardwareProfile.nix { inherit inputs cell; })

      cell.nixosProfiles.services.minidlna-and-torrent

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:1a:ff";
        # deploy.params.lan.ipv4 = "10.11.1.122/24";
        deploy.params.lan.ipv4 = "192.168.1.133/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23e7e5ff";

        services.trezord.enable = false;
        security.pam.u2f.enable = false;
        hardware.ledger.enable = false;
        hardware.nitrokey.enable = false;
      }

      ({ pkgs, lib, ... }: {
        home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }];

        home-manager.users.admin.gui.enable = false;
        home-manager.users.admin.fonts.fontconfig.enable = false;

        home-manager.users.admin.programs.man.enable = lib.mkForce false;
        home-manager.users.admin.programs.man.generateCaches = lib.mkForce false;

        services.geoclue2.enable = lib.mkForce false;
        services.localtimed.enable = lib.mkForce false;

        location.provider = "manual";
        location.longitude = 50.123929;
        location.latitude = 8.6402113;

        networking.networkmanager.enable = false;
        networking.wireless.enable = false;

        systemd.network.networks.local-eth.matchConfig.Name = "end0";

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
