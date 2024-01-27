{ inputs, cell, ... }:

{
  # https://sourceware.org/lvm2/
  services.lvm.dmeventd.enable = true;
  services.lvm.boot.vdo.enable = true;
  services.lvm.boot.thin.enable = true;
}
