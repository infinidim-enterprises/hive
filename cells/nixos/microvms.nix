{ inputs, cell, ... }:
{
  # std //nixos/microvms/dev:run
  dev = inputs.hive.lib.ops.mkMicrovm {

    imports = [
      cell.nixosSuites.base
      cell.nixosConfigurations.marauder.bee.home.nixosModules.default
      { nixpkgs.pkgs = cell.nixosConfigurations.marauder.bee.pkgs; }
    ];

    config.documentation.enable = false;

    microvm.hypervisor = "qemu";
    microvm.shares = [
      {
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
  };
}
