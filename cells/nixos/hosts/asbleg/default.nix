{ inputs, cell, ... }:
let
  inherit (builtins) toString baseNameOf;
  # inherit (inputs.nixpkgs) system; # FIXME: Why does it default to aarch64-linux?
  system = "x86_64-linux";
in

rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    # nixpkgs-unstable
    pkgs = import inputs.nixos-24-11 {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        # ISSUE: (emacs30.1): https://github.com/doomemacs/doomemacs/issues/8293
        "emacs29-pgtk"
        "emacs-pgtk-29.4"
        "emacs-pgtk-with-packages-29.4"
        "emacs-pgtk-with-doom-29.4"
        # CVE-2024-53920
        # CVE-2025-1244
      ];

      overlays = cell.overlays.default_desktop;
    };
  };

  imports =
    cell.nixosSuites.desktop
    # ++ [ cell.nixosProfiles.desktop.rdpserver ] # LightDM login via xrdp
    ++ cell.nixosSuites.networking
    ++ cell.nixosSuites.virtualization
    ++ [ (cell.lib.mkHome "vod" "zsh") ]
    ++ [
      bee.home.nixosModules.home-manager
      { home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }]; }
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      ({ pkgs, ... }:
        {
          systemd.network.networks.local-eth.matchConfig.Name = "eno1";
          networking.wireless.enable = false;
          networking.networkmanager.enable = true;
          environment.systemPackages = with pkgs; [ ventoy-full ];
        })

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:ba:ff";
        # deploy.params.lan.ipv4 = "10.11.1.122/24";
        deploy.params.lan.ipv4 = "192.168.1.135/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e1ff";
      }

      ({ pkgs, ... }: {
        systemd.network.networks.lan = {
          addresses = [
            (cell.lib.networkdSyntax {
              inherit pkgs;
              Address = "192.168.1.135/24";
            })
          ];
          networkConfig.Gateway = "192.168.1.1";
        };
      })

    ];
}
