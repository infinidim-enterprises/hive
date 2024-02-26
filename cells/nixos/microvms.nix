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
        stumpwm-new
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
      bee.home.nixosModules.default
      { nixpkgs.pkgs = bee.pkgs; }
      ({ pkgs, ... }: {
        boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
        boot.zfs.enableUnstable = true;
        boot.zfs.removeLinuxDRM = true;
      })
    ];

    documentation.enable = false;
    services.openssh.enable = true;

    networking.hostId = "23f7e2ff";
    networking.hostName = "marauder";

    services.getty.autologinUser = "admin";

    nix.settings.auto-optimise-store = false;
    nix.optimise.automatic = false;

    microvm.hypervisor = "qemu";
    microvm.vcpu = 4;
    microvm.mem = 4 * 1024;

    microvm.interfaces = [{
      type = "user";
      id = "vm-qemu-1";
      mac = "00:02:00:01:01:00";
    }];

    microvm.forwardPorts = [{
      from = "host";
      host.port = 5999;
      guest.port = 22;
    }];

    # NOTE: home-manager requires a writable store!
    microvm.writableStoreOverlay = "/nix/.rw-store";
    microvm.volumes = [{
      image = "/tmp/nix-store-overlay.img";
      mountPoint = "/nix/.rw-store";
      size = 2048;
    }];

    microvm.shares = [
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
