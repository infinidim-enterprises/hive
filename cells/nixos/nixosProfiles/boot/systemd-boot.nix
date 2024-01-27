{ inputs, cell, ... }:

{ lib, ... }:
let inherit (lib) mkDefault; in
{
  boot.loader.timeout = mkDefault 0;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = mkDefault true;
}
