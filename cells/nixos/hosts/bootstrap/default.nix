{ inputs, cell, host ? null, ... }:
let
  inherit (builtins)
    isNull
    hasAttr
    baseNameOf;
  inherit (inputs.nixpkgs-lib.lib)
    optionals
    optionalString;

  hasDiskoConfig = hasAttr host cell.diskoConfigurations;
  # hasImpermanenceConfig =
  #   let
  #     inherit (inputs.self.colmenaHive.nodes."nixos-${host}") config;
  #   in
  #   hasAttr "persistence" config.environment;
in

rec {
  bee = {
    #  inherit (inputs.nixpkgs) system;
    system = "x86_64-linux";
    home = inputs.home-unstable;
    pkgs = import inputs.nixos {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = cell.overlays.base;
    };
  };

  imports =
    cell.nixosSuites.base # NOTE: sops-nix is absent, since it's an installer image!
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager
      (import ./_hardwareProfile.nix { inherit inputs cell; })

      ({ pkgs, ... }: {
        systemd.network.networks.local-eth.matchConfig.Name = "eno1";
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
      })
      {
        deploy.enable = true;
        deploy.params.hidpi.enable = false;
        deploy.params.lan.mac = "16:07:77:ff:bf:ff";
        deploy.params.lan.ipv4 = "10.11.1.125/24";
        deploy.params.lan.dhcpClient = false;

        networking.hostName =
          (optionalString (! isNull host) "${host}-") +
          (baseNameOf ./.);
        networking.hostId = "23d7efff";
      }
      ({ lib, config, ... }: {
        systemd.network.networks.lan = {
          addresses = [{ addressConfig.Address = "10.11.1.125/24"; }];
          networkConfig.Gateway = "10.11.1.1";
        };
      })
    ] ++ optionals (! isNull host && hasDiskoConfig) [
      inputs.disko.nixosModules.disko
      cell.nixosProfiles.boot.systemd-boot
      cell.nixosProfiles.filesystems.impermanence.default
      ({ lib, ... }: {
        disko.devices = cell.diskoConfigurations.${host} { inherit lib; };
      })
    ];
}
