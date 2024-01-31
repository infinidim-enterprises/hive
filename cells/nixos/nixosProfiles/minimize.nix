# https://discourse.nixos.org/t/how-to-have-a-minimal-nixos/22652/4
{ inputs, cell, ... }:

{ modulesPath, pkgs, lib, ... }:
{
  disabledModules = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
  ];

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
  ];

  environment.noXlibs = true;
  documentation.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;

  boot.initrd.includeDefaultModules = lib.mkDefault false;
  environment.defaultPackages = [ pkgs.perl ];

  services.journald.extraConfig = ''
    SystemMaxUse=128M
  '';
}
