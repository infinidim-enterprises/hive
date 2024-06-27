{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = "solarized-sddm";
  environment.systemPackages = [ inputs.cells.common.packages.solarized-sddm ];
}
