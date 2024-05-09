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
    pkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = with cell.overlays;
        base ++
        desktop ++
        emacs ++
        developer;
    };
  };

  imports =
    cell.nixosSuites.desktop
    ++ cell.nixosSuites.networking
    ++ cell.nixosSuites.virtualization
    ++ [ inputs.cells.secrets.nixosProfiles.common ]
    ++ [ (cell.lib.mkHome "vod" "zsh") ]
    ++ [
      bee.home.nixosModules.home-manager
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      ({ pkgs, ... }:
        {
          systemd.network.networks.local-eth.matchConfig.Name = "eno1";
          networking.wireless.enable = false;
          networking.networkmanager.enable = true;
          environment.systemPackages = with pkgs; [ networkmanagerapplet ventoy-full ];
        })

      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:ba:ff";
        deploy.params.lan.ipv4 = "10.11.1.122/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e1ff";

        # services.redshift.brightness.night = "0.85";
        # services.redshift.brightness.day = "0.85";
      }

      ({ lib, config, ... }: {
        systemd.network.networks.lan = {
          addresses = [{ addressConfig.Address = "10.11.1.122/24"; }];
          networkConfig.Gateway = "10.11.1.1";
        };
      })

    ];
}
