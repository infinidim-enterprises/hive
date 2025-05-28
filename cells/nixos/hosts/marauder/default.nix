{ inputs, cell, ... }:
let
  inherit (builtins) baseNameOf;
in

rec {
  bee = {
    # inherit (inputs.nixpkgs) system;
    system = "x86_64-linux";
    home = inputs.home-unstable;
    pkgs = import inputs.nixos {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = cell.overlays.default_desktop;
    };
  };

  imports =
    let
      baseReqs = [
        bee.home.nixosModules.home-manager
        (import ./_hardwareProfile.nix { inherit inputs cell; })
        (cell.lib.mkHome "vod" "zsh")
        { home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }]; }
      ];
    in

    cell.nixosSuites.desktop
    ++ cell.nixosSuites.networking
    ++ baseReqs
    ++ [{

      deploy.enable = true;
      deploy.params.hidpi.enable = false;
      deploy.params.lan.mac = "16:07:77:ff:bf:ff";
      deploy.params.lan.ipv4 = "10.11.1.125/24";
      deploy.params.lan.dhcpClient = false;

      networking.hostName = baseNameOf ./.;
      networking.hostId = "23d5e2ff";

      networking.wireless.enable = false;
      networking.networkmanager.enable = true;

      systemd.network.networks.local-eth.matchConfig.Name = "eno1";
      systemd.network.networks.lan = {
        addresses = [{ addressConfig.Address = "10.11.1.125/24"; }];
        networkConfig.Gateway = "10.11.1.1";
      };
    }];
}
