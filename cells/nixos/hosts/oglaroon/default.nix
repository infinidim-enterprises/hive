{ inputs, cell, ... }:
let
  inherit (builtins) baseNameOf;
  system = "x86_64-linux";
in

rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixos {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = cell.overlays.default_desktop ++ cell.overlays.llm;
      config.permittedInsecurePackages = [ "python3.12-ecdsa-0.19.1" "mbedtls-2.28.10" ];
    };
  };

  imports =
    cell.nixosSuites.desktop
    ++ cell.nixosSuites.networking
    ++ cell.nixosSuites.virtualization
    ++ [ (cell.lib.mkHome "vod" "zsh") ]
    ++ [
      bee.home.nixosModules.home-manager
      { home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }]; }
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      cell.nixosProfiles.desktop.printer-kyocera
      # TODO: inputs.cells.llm.nixosProfiles.amdgpu

      {
        systemd.network.networks.local-eth.matchConfig.Name = "eno1";
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
      }

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:bf:ff";
        deploy.params.lan.ipv4 = "10.11.1.125/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e2ff";
      }
      ({ pkgs, ... }: {
        systemd.network.networks.lan = {
          addresses = [
            (cell.lib.networkdSyntax {
              inherit pkgs;
              Address = "10.11.1.125/24";
            })
          ];
          networkConfig.Gateway = "10.11.1.1";
        };
      })
    ];
}
