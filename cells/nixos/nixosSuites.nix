{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  users = inputs.cells.home.users.nixos;
in
{

  base = with cell.nixosProfiles; [
    #       [ ({ config, ... }: (cell.lib.mkHome "admin" config.networking.hostName "zsh")) ] ++
    #       [ cell.userProfiles.root ];
    #     inputs.cells.secrets.nixosProfiles.common

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
  # [{ _module.args = { inherit (inputs) self; }; }] ++
  [ cell.nixosModules.deploy ] ++
  [ inputs.cells.common.nixosProfiles.nix-config ];

  networking = [
    cell.nixosProfiles.networking.networkd
    cell.nixosProfiles.networking.firewall
    cell.nixosProfiles.networking.openssh
  ];

  virtualization.vod = {
    imports = [
      cell.nixosProfiles.virtualization.libvirtd
      cell.nixosProfiles.virtualization.docker
      # cell.nixosProfiles.nvidia
      ({ config, lib, ... }:
        let inherit (lib) mkIf hasAttrByPath; in
        mkIf (hasAttrByPath [ "home-manager" ] config) {
          # home-manager.sharedModules = [ cell.homeProfiles.libvirtd ];
        })

      ({ config, lib, ... }:
        let inherit (lib) optionals; in
        {
          users.users."vod" = {
            extraGroups = with config.virtualisation;
              optionals docker.enable [ "docker" ] ++
              optionals podman.enable [ "podman" ] ++
              optionals libvirtd.enable [ "libvirtd" ];
          };
        })
    ];
  };

}
