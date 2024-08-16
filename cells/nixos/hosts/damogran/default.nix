{ inputs, cell, ... }:
let
  inherit (builtins) toString baseNameOf;
  # inherit (inputs.nixpkgs) system; # FIXME: Why does it default to aarch64-linux?
  system = "aarch64-linux";
in

rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
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
        deploy.params.lan.ipv4 = "192.168.1.133/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName = baseNameOf ./.;
        networking.hostId = "23d7e1ff";
      }

      ({ lib, config, ... }: {
        systemd.network.networks.lan = {
          addresses = [{ addressConfig.Address = "192.168.1.133/24"; }];
          networkConfig.Gateway = "192.168.1.1";
        };
      })

    ];
}
