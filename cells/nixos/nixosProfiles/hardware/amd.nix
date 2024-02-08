{ inputs, cell, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-pstate
    common-cpu-amd-raphael-igpu
    common-gpu-amd
  ];

  hardware.cpu.amd.updateMicrocode = true;
}
