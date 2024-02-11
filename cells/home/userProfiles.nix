{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  extraGroups = [
    "backup"
    "disk"
    "lp"

    "audio"
    "sound"
    "video"
    "plugdev"

    "media"
    "input"

    "network"
    "systemd-journal"

    "dialout"
  ];
in

{
  extraGroupsMod = user:
    { config, ... }:
      with lib;
      mkMerge [
        (mkIf config.virtualisation.libvirtd.enable
          {
            home-manager.users.${user}.imports = [
              cell.homeProfiles.virtualisation.libvirtd
            ];
          })
        {
          users.users.${user}.extraGroups = (attrNames
            (filterAttrs
              (n: v: elem n extraGroups)
              config.users.groups)) ++
          optional config.virtualisation.docker.enable "docker" ++
          optional config.virtualisation.podman.enable "podman" ++
          optional config.virtualisation.libvirtd.enable "libvirtd" ++
          optional config.programs.wireshark.enable "wireshark" ++
          optional config.hardware.nitrokey.enable "nitrokey" ++
          optional config.networking.networkmanager.enable "networkmanager" ++
          optional config.hardware.pulseaudio.enable "pulse-access" ++
          optional config.programs.adb.enable "adbusers" ++
          optional config.services.trezord.enable "trezord";
        }
      ];

  root = { config, ... }: {
    users.users.root = {
      hashedPasswordFile = config.sops.secrets.root-password.path;
      inherit (config.users.users.vod) openssh;
    };

  };
} // inputs.cells.common.lib.importers.importProfilesRakeleaves {
  src = ./userProfiles;
  inputs = { inherit cell inputs; };
}
