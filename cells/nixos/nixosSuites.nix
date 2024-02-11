{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
in
{

  base = with cell.nixosProfiles; [
    sudo
    earlyoom
    hardware.tlp
    hardware.fwupd
    core.locale
    core.console-solarized
    core.boot-config
    core.packages
    core.shell-defaults
  ] ++
  [ inputs.cells.secrets.nixosProfiles.common ] ++
  [ ({ config, ... }: (cell.lib.mkHome "admin" config.networking.hostName "zsh")) ] ++
  [ inputs.cells.home.userProfiles.root ] ++
  # [{ _module.args = { inherit (inputs) self; }; }] ++
  [ cell.nixosModules.deploy ] ++
  [ inputs.cells.common.nixosProfiles.nix-config ];

  networking = [
    cell.nixosProfiles.networking.networkd
    cell.nixosProfiles.networking.firewall
    cell.nixosProfiles.networking.openssh
  ];

  virtualization = {
    imports = [
      cell.nixosProfiles.virtualization.libvirtd
      cell.nixosProfiles.virtualization.docker
    ];
  };

}
