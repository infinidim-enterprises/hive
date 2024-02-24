{ inputs, cell, ... }:
let
  bee = {
    system = "x86_64-linux";
    # inherit (inputs.nixpkgs) system;
    home = inputs.home-unstable;
    pkgs = import inputs.nixpkgs-unstable {
      inherit (inputs.nixpkgs) system;
      config.allowUnfree = true;
      overlays = with inputs.cells.common.overlays; [
        sources
        nixpkgs-unstable-overrides
        nixpkgs-master-overrides
      ];
    };
  };

in
{
  # std //nixos/microvms/dev:run
  dev = inputs.std.lib.ops.mkMicrovm {
    inherit bee;
    imports = cell.nixosSuites.base ++ [
      (import "${inputs.hive}/src/beeModule.nix" { nixpkgs = bee.pkgs; })
      cell.nixosConfigurations.marauder.bee.home.nixosModules.default
      { nixpkgs.pkgs = cell.nixosConfigurations.marauder.bee.pkgs; }
    ];

    documentation.enable = false;
    services.openssh.enable = true;
    networking.hostId = "23f7e2ff";

    services.getty.autologinUser = "admin";

    nix.settings.auto-optimise-store = false;
    nix.optimise.automatic = false;

    microvm.vcpu = 4;
    microvm.mem = 4 * 1024;
    microvm.hypervisor = "qemu";

    microvm.writableStoreOverlay = "/nix/.rw-store";

    microvm.volumes = [{
      image = "/tmp/nix-store-overlay.img";
      mountPoint = "/nix/.rw-store";
      size = 2048;
    }];

    microvm.shares = [
      # {
      #   proto = "virtiofs";
      #   tag = "root";
      #   source = "/tmp/mvm.root";
      #   mountPoint = "/";
      #   neededForBoot = true;
      # }

      {
        # proto = "virtiofs";
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
  };
}
