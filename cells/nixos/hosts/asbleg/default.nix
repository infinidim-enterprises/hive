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
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "python3.12-ecdsa-0.19.1"
        "mbedtls-2.28.10"
        # ISSUE: (emacs30.1): https://github.com/doomemacs/doomemacs/issues/8293
        # "emacs29-pgtk"
        # "emacs-pgtk-29.4"
        # "emacs-pgtk-with-packages-29.4"
        # "emacs-pgtk-with-doom-29.4"
        # CVE-2024-53920
        # CVE-2025-1244
      ];

      overlays = cell.overlays.default_desktop ++ [
        inputs.cells.common.overlays.minidlna
        inputs.cells.common.overlays.arr
      ];
    };
  };

  imports =
    cell.nixosSuites.desktop
    # ++ [ cell.nixosProfiles.desktop.rdpserver ] # LightDM login via xrdp
    ++ cell.nixosSuites.networking
    ++ cell.nixosSuites.virtualization
    ++ [ (cell.lib.mkHome "vod" "zsh") ]
    ++ [

      cell.nixosProfiles.services.multimedia-downloads

      bee.home.nixosModules.home-manager
      { home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }]; }
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      {
        systemd.network.networks.local-eth.matchConfig.Name = "eno1";
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
      }

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:ba:ff";
        # deploy.params.lan.ipv4 = "10.11.1.122/24";
        deploy.params.lan.ipv4 = "192.168.0.135/24";
        deploy.params.lan.dhcpClient = false;

        deploy.params.lan.dnsForwarder = true; # NOTE: expose adguardhome to local network

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e1ff";
      }

      ({ pkgs, ... }: {
        systemd.network.networks.lan = {
          addresses = [
            (cell.lib.networkdSyntax {
              inherit pkgs;
              Address = "192.168.0.135/24";
            })
          ];
          networkConfig.Gateway = "192.168.0.1";
        };
      })

    ];
}
