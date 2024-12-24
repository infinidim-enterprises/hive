{ inputs, cell, ... }:
let
  inherit (builtins) toString baseNameOf;
  system = "x86_64-linux";
in

rec {
  bee = {
    inherit system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixos-24-11 {
      inherit system;
      config.allowUnfree = true;
      overlays = cell.overlays.base;
    };
  };

  imports =
    cell.nixosSuites.cli
    ++ cell.nixosSuites.networking
    ++ [
      bee.home.nixosModules.home-manager
      (import ./_hardwareProfile.nix { inherit inputs cell; })
      {
        deploy.enable = true;
        deploy.publicHost.enable = true;

        networking.hostName = baseNameOf ./.;

        networking.wireless.enable = false;
        networking.networkmanager.enable = false;

        services.openssh.ports = [ 22 65522 ];

        home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }];
      }
    ];
}
