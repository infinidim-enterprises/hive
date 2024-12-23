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
        # networking.hostId = "23e5e5ff";

        networking.wireless.enable = false;
        networking.networkmanager.enable = false;

        home-manager.sharedModules = [{ home.enableNixpkgsReleaseCheck = false; }];
      }

      ({ pkgs, lib, modulesPath, ... }: {
        imports = [ "${toString modulesPath}/virtualisation/google-compute-image.nix" ];

        systemd.services.google-guest-agent.enable = false;
        systemd.services.google-guest-agent.wantedBy = lib.mkForce [ ];

        systemd.services.google-startup-scripts.enable = false;
        systemd.services.google-startup-scripts.wantedBy = lib.mkForce [ ];

        systemd.services.google-shutdown-scripts.enable = false;
        systemd.services.google-shutdown-scripts.wantedBy = lib.mkForce [ ];

        system.nixos.label = baseNameOf ./.;
        system.nixos.versionSuffix = "_gce";
      })
    ];
}
