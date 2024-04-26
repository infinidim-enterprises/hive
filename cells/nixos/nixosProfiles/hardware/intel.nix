{ inputs, cells, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
  ];
}
